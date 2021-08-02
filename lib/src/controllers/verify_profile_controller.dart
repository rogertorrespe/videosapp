import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/user_controller.dart';
import '../models/gender.dart';
import '../models/verify_profile_model.dart';
import '../repositories/verify_repository.dart' as verifyRepo;

class VerifyProfileController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  GlobalKey<FormState> formKey;
  PanelController pc = new PanelController();
  bool showLoader = false;
  final picker = ImagePicker();
  File image;
  Gender selectedGender;
  String name = '';
  String address = '';
  String document1 = '';
  String document2 = '';
  String verified = '';
  String verifiedText = '';
  String submitText = 'Submit';
  String emailErr = '';
  String nameErr = '';
  String addressErr = '';
  String document1Err = '';
  String reason = '';
  ScrollController scrollController;
  TextEditingController nameController;
  TextEditingController addressController;
  UserController userCon;
  VerifyProfileModel verifyProfileCon = new VerifyProfileModel();

  VerifyProfileController() {
    fetchVerifyInformation();
  }

  @override
  void initState() {
    scrollController = new ScrollController();
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_verifyProfilePage');
    formKey = new GlobalKey<FormState>();
    super.initState();
  }

  fetchVerifyInformation() async {
    showLoader = true;
    scrollController = new ScrollController();
    verifyRepo.fetchVerifyInformation().then((userValue) {
      print("userValue");
      print(userValue.toJSON());
      showLoader = false;
      setState(() {
        verified = userValue.verified;
        nameController = new TextEditingController(text: userValue.name);
        addressController = new TextEditingController(text: userValue.address);
        name = userValue.name;
        address = userValue.address;
        document1 = userValue.document1;
        document2 = userValue.document2;
        if (userValue.verified == "P") {
          verifiedText = "Pending";
          submitText = "Verification Pending";
        } else if (userValue.verified == "A") {
          verifiedText = "Verified";
          submitText = "Verified Already";
        } else if (userValue.verified == "R") {
          verifiedText = "Rejected";
          submitText = "Re-submit";
          reason = userValue.reason;
        } else {
          verifiedText = "Not Applied";
          submitText = "Submit";
        }
      });
    });
    print("userValue1 $address $name $document1 $document2");
  }

  getDocument1(bool isCamera) async {
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
      setState(() {
        document1 = image.path;
      });
    }
  }

  getDocument2(bool isCamera) async {
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
      setState(() {
        document2 = image.path;
      });
    }
  }

  Future<void> update() async {
    print("address  $address  ${address.length}, Name $name");
    String patttern = r'^[a-z A-Z,.\-]+$';
    RegExp regExp = new RegExp(patttern);
    if (name.length == 0) {
      nameErr = 'Please enter full name';
    } else if (!regExp.hasMatch(name)) {
      nameErr = 'Please enter valid full name';
    }

    print("address.length");
    print(address.length);
    if (address.length == 0) {
      addressErr = "Address Field is required";
    } else {
      addressErr = "";
    }
    if (document1.length == 0) {
      document1Err = "Front Side of ID document is required";
    } else {
      document1Err = "";
    }

    if (nameErr == '' && addressErr == '' && document1Err == '') {
      showLoader = true;
      Map<String, String> data = {};
      data['name'] = name;
      data['address'] = address;
      data['document1'] = document1;
      if (document2 != '') {
        data['document2'] = document2;
      }
      verifyRepo.update(data).then((value) {
        print("response value");
        print(value);
        showLoader = false;
        var response = json.decode(value);
        if (response['status'] == 'success') {
          Navigator.of(scaffoldKey?.currentContext).popAndPushNamed('/verification-page');
        }
      }).catchError((e) {
        print("Error Catched");
        print(e);
        showLoader = false;
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text("There is some error"),
        ));
      });
    } else {
      print("$nameErr == '' && $addressErr == '' && $document1Err == ''");
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
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (addressErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        addressErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (document1Err != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        document1Err,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 45,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      gradient: Gradients.blush,
                    ),
                    child: Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          fontFamily: 'RockWellStd',
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
