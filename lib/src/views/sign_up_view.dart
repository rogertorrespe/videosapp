import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/helper.dart';
import '../models/login_screen_model.dart';
import '../repositories/login_page_repository .dart' as loginRepo;
import '../repositories/settings_repository.dart' as settingRepo;

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends StateMVC<SignUpView> {
  UserController _con;
  _SignUpViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: loginRepo.LoginPageData,
        builder: (context, LoginScreenData data, _) {
          return ModalProgressHUD(
            progressIndicator: Helper.showLoaderSpinner(Colors.white),
            inAsyncCall: _con.showLoader,
            child: SafeArea(
              child: Scaffold(
                // extendBodyBehindAppBar: true,
                backgroundColor: settingRepo.setting.value.bgColor,
                appBar: AppBar(
                  backgroundColor: settingRepo.setting.value.bgColor,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: settingRepo.setting.value.iconColor,
                    ),
                  ),
                  title: Column(
                    children: [
                      Text(
                        "Register",
                        style: TextStyle(
                          color: settingRepo.setting.value.headingColor,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'QueenCamelot',
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        color: settingRepo.setting.value.dividerColor,
                        height: .4,
                        width: MediaQuery.of(context).size.width * .3,
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),
                key: _con.userScaffoldKey,
                body: SingleChildScrollView(
                  child: Container(
                    // height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    color: settingRepo.setting.value.bgColor,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Form(
                              key: _con.registerFormKey,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              child: Column(
                                children: [
                                  TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: _con.fullNameController,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'RockWellStd',
                                      fontSize: 14.0,
                                      color: settingRepo.setting.value.textColor,
                                    ),
                                    keyboardType: TextInputType.text,
                                    onChanged: (String val) {
                                      _con.fullName = val;
                                    },
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                        wordSpacing: 2.0,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo.setting.value.dividerColor != null
                                              ? settingRepo.setting.value.dividerColor
                                              : Colors.grey[400],
                                          width: 0.5,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo.setting.value.textColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo.setting.value.textColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 0.5,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(top: 12),
                                      hintText: "Enter Your Full Name",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    validator: (value) {
                                      return _con.validateField(value, "Full Name");
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.015,
                                  ),
                                  TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: _con.emailController,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'RockWellStd',
                                      fontSize: 14.0,
                                      color: settingRepo.setting.value.textColor,
                                    ),
                                    validator: _con.validateEmail,
                                    keyboardType: TextInputType.text,
                                    onChanged: (String val) {
                                      _con.email = val;
                                    },
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                        wordSpacing: 2.0,
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo.setting.value.dividerColor != null
                                              ? settingRepo.setting.value.dividerColor
                                              : Colors.grey[400],
                                          width: 0.5,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo.setting.value.dividerColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: settingRepo.setting.value.dividerColor,
                                          width: 0.5,
                                        ),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 0.5,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.only(top: 12),
                                      hintText: "Enter Your Email",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.03,
                                  ),
                                  RaisedButton(
                                    padding: EdgeInsets.all(0),
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: settingRepo.setting.value.buttonColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Next',
                                          style: TextStyle(
                                            color: settingRepo.setting.value.buttonTextColor,
                                            fontSize: 20,
                                            fontFamily: 'RockWellStd',
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      print("_con.email");
                                      print(_con.email);
                                      _con.ifEmailExists(_con.email);
                                      // print(check);
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.03,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005,
                          ),
                          (!Platform.isAndroid && data.appleLogin != null && data.appleLogin == true) ||
                                  (data.googleLogin != null && data.googleLogin == true) ||
                                  (data.fbLogin != null && data.fbLogin == true)
                              ? Text(
                                  "OR",
                                  style: TextStyle(
                                    color: settingRepo.setting.value.textColor,
                                    fontSize: 22,
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005,
                          ),
                          (!Platform.isAndroid && data.appleLogin != null && data.appleLogin == true)
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                )
                              : Container(),
                          (!Platform.isAndroid && data.appleLogin != null && data.appleLogin == true)
                              ? Container(
                                  constraints: BoxConstraints(maxWidth: 350),
                                  child: Center(
                                    child: GestureDetector(
                                      child: Image.asset(
                                        'assets/images/signin-with-apple.png',
                                        fit: BoxFit.fill,
                                        width: MediaQuery.of(context).size.width - 100,
                                      ),
                                      onTap: () async {
                                        _con.signInWithApple();
                                      },
                                    ),
                                  ),
                                )
                              : Container(),
                          data.googleLogin != null && data.googleLogin == true
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                )
                              : Container(),
                          data.googleLogin != null && data.googleLogin == true
                              ? Container(
                                  constraints: BoxConstraints(maxWidth: 350),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        _con.loginWithGoogle();
                                      },
                                      child: Image.asset(
                                        'assets/images/google-b.png',
                                        fit: BoxFit.fill,
                                        width: MediaQuery.of(context).size.width - 100,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          data.fbLogin != null && data.fbLogin == true
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                )
                              : Container(),
                          data.fbLogin != null && data.fbLogin == true
                              ? Container(
                                  constraints: BoxConstraints(maxWidth: 350),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        _con.loginWithFB();
                                      },
                                      child: Image.asset(
                                        'assets/images/facebook-b.png',
                                        fit: BoxFit.fill,
                                        width: MediaQuery.of(context).size.width - 100,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              child: Text(
                                data.privacyPolicy != null
                                    ? data.privacyPolicy
                                    : "By continuing you agree to ${GlobalConfiguration().get('app_name')} terms of use and confirm that you have read our privacy policy.",
                                style: TextStyle(
                                  height: 1.55,
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  _con.launchURL("${GlobalConfiguration().get('base_url')}terms");
                                },
                                child: Text(
                                  "Terms of use",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Container(
                                width: 1,
                                height: 17,
                                color: Colors.white70,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _con.launchURL("${GlobalConfiguration().get('base_url')}privacy-policy");
                                },
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
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

class MyDateTimePicker extends StatefulWidget {
  @override
  _MyDateTimePickerState createState() => _MyDateTimePickerState();
}

class _MyDateTimePickerState extends State<MyDateTimePicker> {
  DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      initialDateTime: _dateTime,
      onDateTimeChanged: (dateTime) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }
}
