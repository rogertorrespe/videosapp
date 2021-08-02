import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/user_profile_controller.dart';
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../models/gender.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import 'showCupertinoDatePicker.dart';

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');
var formatterDate = new DateFormat('dd MMM yyyy');

String minYear = formatterYear.format(minDate);
String maxYear = formatterYear.format(yearBefore);
String initDatetime = formatter.format(yearBefore);

class EditProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  EditProfileView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends StateMVC<EditProfileView> {
  UserProfileController _con;
  int page = 1;
  _EditProfileViewState() : super(UserProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      controller: _con.nameController,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.text,
      onSaved: (String val) {
        usersProfileData.value.name = val;
      },
      onChanged: (String val) {
        usersProfileData.value.name = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Enter Your Name",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor.withOpacity(0.7),
        ),
      ),
    );

    final emailField = TextFormField(
      textAlign: TextAlign.right,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      readOnly: true,
      keyboardType: TextInputType.emailAddress,
      controller: _con.emailController,
      onSaved: (String val) {
        usersProfileData.value.email = val;
      },
      onChanged: (String val) {
        usersProfileData.value.email = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Enter Email",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor.withOpacity(0.7),
        ),
      ),
    );

    final usernameField = TextFormField(
      textAlign: TextAlign.right,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.text,
      controller: _con.usernameController,
      onSaved: (String val) {
        usersProfileData.value.userName = val;
      },
      onChanged: (String val) {
        usersProfileData.value.userName = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Enter Username",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor.withOpacity(0.7),
        ),
      ),
    );

    final mobileField = TextFormField(
      inputFormatters: [
        LengthLimitingTextInputFormatter(13),
      ],
      // maxLength: 13,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      // maxLength: 13,

      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: false,
      keyboardType: TextInputType.phone,
      controller: _con.mobileController,
      onSaved: (String val) {
        usersProfileData.value.mobile = val;
      },
      onChanged: (String val) {
        usersProfileData.value.mobile = val;
      },
      decoration: new InputDecoration(
        counterText: '',
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Enter Mobile No.",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor.withOpacity(0.7),
        ),
      ),
    );

    final bioField = TextFormField(
      textAlign: TextAlign.right,
      maxLength: 80,
      maxLines: null,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.multiline,
      controller: _con.bioController,
      onSaved: (String val) {
        usersProfileData.value.bio = val;
      },
      onChanged: (String val) {
        usersProfileData.value.bio = val;
      },
      decoration: new InputDecoration(
        counterText: "",
        errorStyle: TextStyle(
          color: Color(0xFFf5ae78),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Enter Bio (80 chars)",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor.withOpacity(0.70),
        ),
      ),
    );

    return ValueListenableBuilder(
        valueListenable: usersProfileData,
        builder: (context, EditProfileModel _userProfile, _) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: settingRepo.setting.value.bgColor,
              key: _con.scaffoldKey,
              resizeToAvoidBottomInset: true,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(45.0),
                child: AppBar(
                  leading: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: settingRepo.setting.value.iconColor,
                    ),
                  ),
                  iconTheme: IconThemeData(
                    color: settingRepo.setting.value.iconColor,
                  ),
                  backgroundColor: settingRepo.setting.value.bgColor,
                  title: Text(
                    "PROFILE PICTURE",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: settingRepo.setting.value.headingColor,
                    ),
                  ),
                  centerTitle: true,
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        _con.update();
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(color: settingRepo.setting.value.iconColor, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      shape: CircleBorder(
                        side: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                controller: _con.scrollController,
                child: SlidingUpPanel(
                  controller: _con.pc,
                  isDraggable: false,
                  backdropEnabled: true,
                  panelSnapping: false,
                  color: Color(0xffffffff),
                  maxHeight: 95.0,
                  minHeight: 0,
                  onPanelClosed: () {
                    _con.scrollController.animateTo(
                      0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 1000),
                    );
                  },
                  panel: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _con.getImageOption(true);
                                _con.pc.close();
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/camera.png',
                                    width: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                    child: Text(
                                      "Camera",
                                      style: TextStyle(color: Colors.black, fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _con.getImageOption(false);
                                _con.pc.close();
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/gallery.png',
                                    width: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                    child: Text(
                                      "Gallery",
                                      style: TextStyle(color: Colors.black, fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                  return Scaffold(
                                      appBar: PreferredSize(
                                        preferredSize: Size.fromHeight(45.0),
                                        child: AppBar(
                                          leading: InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              size: 20,
                                              color: settingRepo.setting.value.iconColor,
                                            ),
                                          ),
                                          iconTheme: IconThemeData(
                                            color: Colors.black, //change your color here
                                          ),
                                          backgroundColor: settingRepo.setting.value.bgColor,
                                          title: Text(
                                            "PROFILE PICTURE",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400,
                                              color: settingRepo.setting.value.headingColor,
                                            ),
                                          ),
                                          centerTitle: true,
                                        ),
                                      ),
                                      backgroundColor: settingRepo.setting.value.bgColor,
                                      body: Center(
                                        child: PhotoView(
                                          enableRotation: true,
                                          imageProvider: CachedNetworkImageProvider((_userProfile.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                  _userProfile.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                  _userProfile.largeProfilePic.toLowerCase().contains(".png") ||
                                                  _userProfile.largeProfilePic.toLowerCase().contains(".gif") ||
                                                  _userProfile.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                  _userProfile.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                  _userProfile.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                              ? _userProfile.largeProfilePic
                                              : '${GlobalConfiguration().getString('base_url')}' + "default/user-dummy-pic.png"),
                                        ),
                                      ));
                                }));
                                _con.pc.close();
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/view.png',
                                    width: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                    child: Text(
                                      "View Picture",
                                      style: TextStyle(color: Colors.black, fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  body: ModalProgressHUD(
                    inAsyncCall: _con.showLoader,
                    progressIndicator: Helper.showLoaderSpinner(Colors.black),
                    child: Center(
                        child: Container(
                      color: settingRepo.setting.value.bgColor,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20),
                          Stack(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _con.scrollController.animateTo(
                                      70,
                                      curve: Curves.easeOut,
                                      duration: const Duration(milliseconds: 1000),
                                    );
                                    _con.pc.open();
                                  });
                                },
                                child: Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                    border: new Border.all(
                                      color: Colors.white,
                                      width: 5.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image: new CachedNetworkImageProvider(
                                            (_userProfile.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                    _userProfile.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                    _userProfile.smallProfilePic.toLowerCase().contains(".png") ||
                                                    _userProfile.smallProfilePic.toLowerCase().contains(".gif") ||
                                                    _userProfile.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                    _userProfile.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                    _userProfile.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                ? _userProfile.smallProfilePic
                                                : '${GlobalConfiguration().getString('base_url')}' + "default/user-dummy-pic.png",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _con.scrollController.animateTo(
                                          70,
                                          curve: Curves.easeOut,
                                          duration: const Duration(milliseconds: 1000),
                                        );
                                        _con.pc.open();
                                      });
                                    },
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey[200],
                                      size: 25.0,
                                    ),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                            child: Container(
                              child: Form(
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                key: _con.formKey,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                    2,
                                                    5,
                                                    0,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    "Username",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: SizedBox(
                                                height: 30.0,
                                                width: MediaQuery.of(context).size.width - 150,
                                                child: Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                    child: usernameField,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "Name",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: SizedBox(
                                                height: 30.0,
                                                width: MediaQuery.of(context).size.width - 150,
                                                child: Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                    child: nameField,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "Email",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: SizedBox(
                                                height: 30.0,
                                                width: MediaQuery.of(context).size.width - 150,
                                                child: Container(
                                                  child: Padding(padding: const EdgeInsets.fromLTRB(2, 5, 0, 0), child: emailField),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "Gender",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30.0,
                                              width: MediaQuery.of(context).size.width - 140,
                                              child: Container(
                                                child: Theme(
                                                  data: Theme.of(context).copyWith(
                                                    canvasColor: settingRepo.setting.value.buttonColor,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: DropdownButtonHideUnderline(
                                                      child: new DropdownButton<Gender>(
                                                        iconEnabledColor: Colors.white,
                                                        style: new TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                        ),
                                                        value: _con.selectedGender,
                                                        onChanged: (Gender newValue) {
                                                          usersProfileData.value.gender = newValue.value;
                                                          setState(() {
                                                            _con.selectedGender = newValue;
                                                          });
                                                        },
                                                        items: _con.gender.map((Gender user) {
                                                          return new DropdownMenuItem<Gender>(
                                                            value: user,
                                                            child: new Text(
                                                              user.name,
                                                              textAlign: TextAlign.right,
                                                              style: new TextStyle(
                                                                color: settingRepo.setting.value.textColor,
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "Mobile",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: SizedBox(
                                                height: 30.0,
                                                width: MediaQuery.of(context).size.width - 150,
                                                child: Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                    child: mobileField,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "DOB",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: SizedBox(
                                                height: 30.0,
                                                width: MediaQuery.of(context).size.width - 150,
                                                child: Container(
                                                  child: Padding(
                                                      padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          showCupertinoDatePicker(context,
                                                              mode: CupertinoDatePickerMode.date,
                                                              initialDateTime: usersProfileData.value.dob,
                                                              leftHanded: false,
                                                              minimumYear: int.parse(minYear),
                                                              maximumYear: int.parse(maxYear), onDateTimeChanged: (DateTime date) {
                                                            DateTime result;
                                                            if (date.year > 0) {
                                                              result = DateTime(date.year, date.month, date.day, usersProfileData.value.dob.hour, usersProfileData.value.dob.minute);
                                                              usersProfileData.value.dob = result;
                                                              usersProfileData.notifyListeners();
                                                            } else {
                                                              // The user has hit the cancel button.
                                                              result = usersProfileData.value.dob;
                                                            }
                                                            _con.onChanged(result);
                                                          });
                                                        },
                                                        child: (usersProfileData.value.dob != null)
                                                            ? Text(formatterDate.format(usersProfileData.value.dob),
                                                                textAlign: TextAlign.right,
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: settingRepo.setting.value.textColor,
                                                                ))
                                                            : Container(),
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 100.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "Bio",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: SizedBox(
                                                height: 100.0,
                                                width: MediaQuery.of(context).size.width - 150,
                                                child: Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                    child: bioField,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
