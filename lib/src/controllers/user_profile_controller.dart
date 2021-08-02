import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/user_controller.dart';
import '../models/edit_profile_model.dart';
import '../models/gender.dart';
import '../repositories/profile_repository.dart' as profRepo;
import '../repositories/user_repository.dart' as userRepo;

class UserProfileController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  GlobalKey<FormState> formKey;
  PanelController pc = new PanelController();
  bool showLoader = false;
  final picker = ImagePicker();
  File image;
  Gender selectedGender;
  String emailErr = '';
  String nameErr = '';
  String mobileErr = '';
  String genderErr = '';
  String currentPasswordErr = '';
  String newPasswordErr = '';
  String confirmPasswordErr = '';
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  ScrollController scrollController;
  TextEditingController nameController;
  TextEditingController emailController;
  TextEditingController mobileController;
  TextEditingController usernameController;
  TextEditingController bioController;
  TextEditingController currentPasswordController;
  TextEditingController newPasswordController;
  GlobalKey<ScaffoldState> blockedUserScaffoldKey;
  TextEditingController confirmPasswordController;
  UserController userCon;
  EditProfileModel userProfileCon = new EditProfileModel();
  List<Gender> gender = <Gender>[const Gender('', 'Select'), const Gender('m', 'Male'), const Gender('f', 'Female'), const Gender('o', 'Other')];
  bool showLoadMore = true;

  bool blockUnblockLoader = false;
  UserProfileController() {
    fetchLoggedInUserInformation();
  }

  @override
  void initState() {
    scrollController = new ScrollController();
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_editProfilePage');
    formKey = new GlobalKey<FormState>();

    blockedUserScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_blockedUserScaffoldPage');
    scrollController = new ScrollController();

    super.initState();
  }

  fetchLoggedInUserInformation() async {
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    profRepo.fetchLoggedInUserInformation().then((userValue) {
      showLoader = false;
      setState(() {
        selectedGender = userValue.gender == 'm'
            ? gender[1]
            : userValue.gender == 'f'
                ? gender[2]
                : userValue.gender == 'o'
                    ? gender[3]
                    : gender[0];

        usernameController = new TextEditingController(text: userValue.userName);
        nameController = new TextEditingController(text: userValue.name);
        emailController = new TextEditingController(text: userValue.email);
        mobileController = new TextEditingController(text: userValue.mobile);
        bioController = new TextEditingController(text: userValue.bio);
      });
    });
  }

  getImageOption(bool isCamera) async {
    if (isCamera) {
      final pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } else {
      final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
    if (image != null) {
      updateProfilePic(image);
    }
  }

  Future updateProfilePic(File file) async {
    setState(() {});
    userCon = UserController();
    showLoader = true;
    profRepo.updateProfilePic(file).then((value) {
      showLoader = false;
      var response = json.decode(value);
      if (response['status'] == 'success') {
        setState(() {
          profRepo.usersProfileData.value.smallProfilePic = response['small_pic'];
          profRepo.usersProfileData.value.largeProfilePic = response['large_pic'];
          profRepo.usersProfileData.notifyListeners();
        });
        userRepo.currentUser.value.userDP = response['large_pic'];
        userRepo.currentUser.notifyListeners();

        userCon.refreshMyProfile();
      } else {
        showLoader = false;
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text("There are some error to upload file"),
        ));
      }
    });
  }

  Future<void> update() async {
    setState(() {});
    if (profRepo.usersProfileData.value.name.contains(" ")) {
      var nameArr = profRepo.usersProfileData.value.name.split(' ');
      profRepo.usersProfileData.value.firstName = nameArr[0];
      profRepo.usersProfileData.value.lastName = nameArr[1];
    } else {
      profRepo.usersProfileData.value.firstName = profRepo.usersProfileData.value.name;
      profRepo.usersProfileData.value.lastName = "";
    }

    profRepo.usersProfileData.value.appToken = userRepo.currentUser.value.token;
    profRepo.usersProfileData.notifyListeners();
    String patttern = r'^[a-z A-Z,.\-]+$';
    RegExp regExp = new RegExp(patttern);

    if (profRepo.usersProfileData.value.name.length == 0) {
      nameErr = "Name Field is required";
    } else if (!regExp.hasMatch(profRepo.usersProfileData.value.name)) {
      nameErr = 'Please enter valid full name';
    } else {
      nameErr = "";
    }
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (profRepo.usersProfileData.value.email.length == 0) {
      emailErr = 'Email Field is required';
    } else if (!regex.hasMatch(profRepo.usersProfileData.value.email)) {
      emailErr = 'You entered invalid email!';
    } else {
      emailErr = '';
    }

    String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp mobRegExp = new RegExp(mobilePattern);
    print(mobRegExp.hasMatch(profRepo.usersProfileData.value.mobile));
    print("printmobile eroor");
    if (profRepo.usersProfileData.value.mobile.length > 0 && !mobRegExp.hasMatch(profRepo.usersProfileData.value.mobile)) {
      print("printmobile eroor");

      mobileErr = 'Please enter valid mobile number';
    } else {
      mobileErr = "";
    }
    if (profRepo.usersProfileData.value.gender == '') {
      genderErr = "Gender Field is required";
    } else {
      genderErr = "";
    }
    if (nameErr == '' && emailErr == '' && genderErr == '' && mobileErr == '') {
      showLoader = true;
      print(json.encode(profRepo.usersProfileData.value.toJson()));
      profRepo.update(profRepo.usersProfileData.value.toJson()).then((value) {
        showLoader = false;
        var response = json.decode(value);
        if (response['status'] == 'success') {
          Navigator.of(scaffoldKey?.currentContext).popAndPushNamed('/my-profile');
        } else {
          showLoader = false;
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(response['msg']),
          ));
        }
      }).catchError((e) {
        showLoader = false;
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text("There is some error updating profile"),
        ));
      });
    } else {
      showAlertDialog(scaffoldKey?.currentContext);
    }
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (nameErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        nameErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (emailErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        emailErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (mobileErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        mobileErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (genderErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        genderErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (currentPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        currentPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (newPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        newPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (confirmPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        confirmPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Container(
                    height: 25,
                    width: 50,
                    decoration: BoxDecoration(gradient: Gradients.blush),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onChanged(value) {
    userProfileCon.dob = value;
  }

  Future<void> changePassword() async {
    if (currentPassword == "") {
      currentPasswordErr = "Current Password is required";
    } else {
      currentPasswordErr = "";
    }
    if (newPassword == "") {
      newPasswordErr = "New Password is required";
    } else {
      newPasswordErr = "";
    }
    if (confirmPassword == "") {
      confirmPasswordErr = "Confirm Password is required";
    } else if (confirmPassword != newPassword) {
      confirmPasswordErr = "Password doesn't match";
    } else {
      confirmPasswordErr = "";
    }

    if (currentPasswordErr == '' && newPasswordErr == '' && confirmPasswordErr == '') {
      setState(() {
        showLoader = true;
      });

      var data = {
        "user_id": userRepo.currentUser.value.userId.toString(),
        "app_token": userRepo.currentUser.value.token,
        "old_password": currentPassword,
        "password": newPassword,
        "confirm_password": confirmPassword,
      };
      profRepo.changePassword(data).then((value) {
        print("changePassword");
        print(data);
        showLoader = false;
        var response = json.decode(value);
        if (response['status'] == 'success') {
          Navigator.of(scaffoldKey?.currentContext).popAndPushNamed('/my-profile');
        } else {
          setState(() {
            showLoader = false;
          });
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(response['msg']),
          ));
        }
      }).catchError((e) {
        setState(() {
          showLoader = false;
        });

        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text("There are som error"),
        ));
      });
    } else {
      showAlertDialog(scaffoldKey?.currentContext);
    }
  }

  getblockedUsers(int page) async {
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    userRepo.getBlockedUsers(page).then((userValue) {
      showLoader = false;
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            getblockedUsers(page);
          }
        }
      });
    });
  }

  blockUnblockUser(userId) async {
    setState(() {
      blockUnblockLoader = true;
    });
    userRepo.blockUser(userId).then((value) async {
      setState(() {
        blockUnblockLoader = false;
      });
      var response = json.decode(value);
      if (response['status'] == 'success') {
        print(response);
        userRepo.userProfile.value.blocked = response['block'] == 'Block' ? 'no' : 'yes';
        userRepo.userProfile.notifyListeners();
        userRepo.blockedUsersData.value.users.removeWhere((element) => element.id == userId);
        userRepo.blockedUsersData.notifyListeners();
        blockedUserScaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(response['msg']),
        ));
      } else {
        blockedUserScaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text("There are some error"),
        ));
      }
    });
  }
}
