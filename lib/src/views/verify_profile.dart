import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/verify_profile_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
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

class VerifyProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  VerifyProfileView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _VerifyProfileViewState createState() => _VerifyProfileViewState();
}

class _VerifyProfileViewState extends StateMVC<VerifyProfileView> {
  VerifyProfileController _con;
  int page = 1;
  _VerifyProfileViewState() : super(VerifyProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      enabled: _con.verified == 'A' || _con.verified == 'P' ? false : true,
      controller: _con.nameController,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.text,
      onSaved: (String val) {
        _con.name = val;
      },
      onChanged: (String val) {
        _con.name = val;
      },
      decoration: new InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(10, 8, 0, 0),
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.5),
        ),
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Enter Your Name",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.dividerColor,
        ),
      ),
    );

    final addressField = TextFormField(
      enabled: _con.verified == 'A' || _con.verified == 'P' ? false : true,
      textAlign: TextAlign.left,
      maxLength: 80,
      maxLines: null,
      minLines: 3,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.multiline,
      controller: _con.addressController,
      onSaved: (String val) {
        _con.address = val;
      },
      onChanged: (String val) {
        _con.address = val;
      },
      decoration: new InputDecoration(
        counterText: "",
        errorStyle: TextStyle(
          color: Color(0xFFf5ae78),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        /*enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        disabledBorder: InputBorder.none,*/
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade600, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade600, width: 0.5),
        ),
        hintText: "Enter Your Address",
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
    AppBar appBar = AppBar(
      iconTheme: IconThemeData(
        color: settingRepo.setting.value.iconColor, //change your color here
      ),
      backgroundColor: settingRepo.setting.value.bgColor,
      title: Text(
        "PROFILE VERIFICATION",
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          color: settingRepo.setting.value.textColor,
        ),
      ),
      centerTitle: true,
      /*actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        _con.update();
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Color(0xff4BB543),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      shape: CircleBorder(
                          side: BorderSide(color: Colors.transparent)),
                    ),
                  ],*/
    );
    return ValueListenableBuilder(
        valueListenable: usersProfileData,
        builder: (context, EditProfileModel _userProfile, _) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: settingRepo.setting.value.bgColor,
              key: _con.scaffoldKey,

              resizeToAvoidBottomInset: false,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(45.0),
                child: appBar,
              ),
              body: ModalProgressHUD(
                inAsyncCall: _con.showLoader,
                color: Colors.white54,
                progressIndicator: Helper.showLoaderSpinner(Colors.black),
                child: SingleChildScrollView(
                  controller: _con.scrollController,
                  child: Center(
                    child: Container(
                      color: settingRepo.setting.value.bgColor,
                      height: MediaQuery.of(context).size.height + appBar.preferredSize.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 0),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  children: [
                                    Center(
                                      child: GradientText(
                                        'STATUS',
                                        shaderRect: Rect.fromLTWH(0.0, 0.0, 50.0, 50.0),
                                        gradient: Gradients.blush,
                                        style: TextStyle(
                                          fontSize: 40.0,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.verified_outlined,
                                          color: _con.verified == 'A'
                                              ? Colors.blueAccent
                                              : _con.verified == 'R'
                                                  ? Colors.redAccent
                                                  : Colors.grey,
                                          size: 40,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Center(
                                          child: Text(
                                            "${_con.verifiedText}",
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: _con.verified == 'R' ? Colors.redAccent : settingRepo.setting.value.textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _con.reason != ''
                              ? Center(
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                      color: Colors.redAccent,
                                    )),
                                    child: Text(
                                      "${_con.reason}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: _con.verified == 'R' ? Colors.redAccent : settingRepo.setting.value.textColor,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 10),
                          /* _con.verified == 'A'
                              ? Container(
                                  width: config.App(context).appWidth(50),
                                  child: Center(
                                    child: Icon(
                                      Icons.verified_outlined,
                                      size: 200,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                )
                              : Container(),*/
                          _con.verified == 'A' ? SizedBox(height: 20) : Container(),
                          _con.verified == 'A'
                              ? Container()
                              : Text(
                                  "Apply For Profile Verification now",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: settingRepo.setting.value.textColor,
                                    // color: Colors.pinkAccent,
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 1,
                            color: settingRepo.setting.value.dividerColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 25,
                              horizontal: 0,
                            ),
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
                                    /*Container(
                                        height: 0.3,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.grey,),*/
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
                                                    "Address",
                                                    style: TextStyle(fontSize: 14, color: settingRepo.setting.value.textColor),
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
                                                    child: addressField,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   height: 0.3,
                                    //   width: MediaQuery.of(context).size.width,
                                    //   color: Colors.grey,
                                    // ),
                                    Text(
                                      "Supporting Document ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        // color: Colors.pinkAccent,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: config.App(context).appWidth(3),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              if (_con.verified == 'A' || _con.verified == 'P') {
                                              } else {
                                                setState(() {
                                                  _con.document1 = "";
                                                });
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return StatefulBuilder(builder: (context, setState) {
                                                      return AlertDialog(
                                                        backgroundColor: settingRepo.setting.value.buttonColor,
                                                        title: Text(
                                                          "Choose File",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 18,
                                                            color: settingRepo.setting.value.textColor,
                                                          ),
                                                        ),
                                                        content: Container(
                                                            height: 70,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: <Widget>[
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: <Widget>[
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: GestureDetector(
                                                                        onTap: () {
                                                                          _con.getDocument1(true);
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Column(
                                                                          children: <Widget>[
                                                                            Icon(
                                                                              Icons.camera_alt,
                                                                              color: settingRepo.setting.value.iconColor,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                              child: Text(
                                                                                "Camera",
                                                                                style: TextStyle(
                                                                                  color: settingRepo.setting.value.iconColor,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        _con.getDocument1(false);
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Column(
                                                                        children: <Widget>[
                                                                          Icon(
                                                                            Icons.perm_media,
                                                                            color: settingRepo.setting.value.iconColor,
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                            child: Text(
                                                                              "Gallery",
                                                                              style: TextStyle(
                                                                                color: settingRepo.setting.value.textColor,
                                                                                fontSize: 14,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            )),
                                                      );
                                                    });
                                                  },
                                                );
                                              }
                                            },
                                            child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              strokeWidth: 1,
                                              dashPattern: [3],
                                              radius: Radius.circular(12),
                                              padding: EdgeInsets.all(6),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(12),
                                                ),
                                                child: _con.document1 == null || _con.document1 == ""
                                                    ? Container(
                                                        height: config.App(context).appHeight(30),
                                                        width: config.App(context).appWidth(40),
                                                        color: settingRepo.setting.value.inactiveButtonColor,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              margin: EdgeInsets.all(10),
                                                              padding: EdgeInsets.all(5),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(100),
                                                                border: Border.all(
                                                                  width: 2,
                                                                  color: settingRepo.setting.value.dividerColor,
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons.add,
                                                                color: settingRepo.setting.value.iconColor,
                                                                size: 20,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Text(
                                                                "Upload Front Side of Id Proof",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: settingRepo.setting.value.textColor,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 18,
                                                            ),
                                                            Icon(
                                                              Icons.add_a_photo_outlined,
                                                              color: settingRepo.setting.value.iconColor,
                                                              size: 35,
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(
                                                        height: config.App(context).appHeight(30),
                                                        width: config.App(context).appWidth(40),
                                                        color: Colors.black54,
                                                        child: Uri.parse(_con.document1).isAbsolute
                                                            ? CachedNetworkImage(
                                                                imageUrl: _con.document1,
                                                                placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                                                fit: BoxFit.fitWidth,
                                                                alignment: Alignment.center,
                                                              )
                                                            : Image.file(
                                                                File(
                                                                  _con.document1,
                                                                ),
                                                              ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: config.App(context).appWidth(8),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (_con.verified == 'A' || _con.verified == 'P') {
                                              } else {
                                              setState(() {
                                                _con.document2 = "";
                                              });
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return StatefulBuilder(builder: (context, setState) {
                                                    return AlertDialog(
                                                      backgroundColor: settingRepo.setting.value.buttonColor,
                                                      title: Text(
                                                        "Choose File",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 18,
                                                          color: settingRepo.setting.value.textColor,
                                                        ),
                                                      ),
                                                      content: Container(
                                                          height: 70,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: <Widget>[
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 20),
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        _con.getDocument2(true);
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Column(
                                                                        children: <Widget>[
                                                                          Icon(
                                                                            Icons.camera_alt,
                                                                            color: settingRepo.setting.value.iconColor,
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                            child: Text(
                                                                              "Camera",
                                                                              style: TextStyle(
                                                                                color: settingRepo.setting.value.iconColor,
                                                                                fontSize: 14,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      _con.getDocument2(false);
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Column(
                                                                      children: <Widget>[
                                                                        Icon(
                                                                          Icons.perm_media,
                                                                          color: settingRepo.setting.value.iconColor,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                          child: Text(
                                                                            "Gallery",
                                                                            style: TextStyle(
                                                                              color: settingRepo.setting.value.textColor,
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          )),
                                                    );
                                                  });
                                                },
                                              );
                                            }
                                            },
                                            child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              strokeWidth: 1,
                                              dashPattern: [3],
                                              radius: Radius.circular(12),
                                              padding: EdgeInsets.all(6),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(12),
                                                ),
                                                child: _con.document2 == null || _con.document2 == ""
                                                    ? Container(
                                                        height: config.App(context).appHeight(30),
                                                        width: config.App(context).appWidth(40),
                                                        color: settingRepo.setting.value.inactiveButtonColor,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              margin: EdgeInsets.all(10),
                                                              padding: EdgeInsets.all(5),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(100),
                                                                border: Border.all(
                                                                  width: 2,
                                                                  color: settingRepo.setting.value.dividerColor,
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons.add,
                                                                color: settingRepo.setting.value.iconColor,
                                                                size: 20,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Text(
                                                                "Upload Back Side of Id Proof",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: settingRepo.setting.value.textColor,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 18,
                                                            ),
                                                            Icon(
                                                              Icons.add_a_photo_outlined,
                                                              color: settingRepo.setting.value.iconColor,
                                                              size: 35,
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(
                                                        height: config.App(context).appHeight(30),
                                                        width: config.App(context).appWidth(40),
                                                        color: settingRepo.setting.value.bgColor.withOpacity(0.6),
                                                        child: Uri.parse(_con.document2).isAbsolute
                                                            ? Image.network(
                                                                _con.document2,
                                                                alignment: Alignment.center,
                                                              )
                                                            : Image.file(
                                                                File(
                                                                  _con.document2,
                                                                ),
                                                              ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        if (_con.verified == 'A' || _con.verified == 'P') {
                                        } else {
                                          _con.update();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                                        child: Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: settingRepo.setting.value.buttonColor,
                                              /*boxShadow: [
                                                BoxShadow(
                                                  color: Colors.lightGreen,
                                                  spreadRadius: 3,
                                                ),
                                              ],*/
                                            ),
                                            height: config.App(context).appWidth(10),
                                            width: config.App(context).appWidth(80),
                                            child: Center(
                                              child: Text(
                                                _con.submitText,
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.buttonTextColor,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
