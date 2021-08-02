import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../models/login_screen_model.dart';
import '../repositories/login_page_repository .dart' as loginRepo;
import '../repositories/settings_repository.dart' as settingRepo;
import '../views/verify_otp_screen.dart';
import 'forgot_password.dart';

class PasswordLoginView extends StatefulWidget {
  @override
  _PasswordLoginViewState createState() => _PasswordLoginViewState();
}

class _PasswordLoginViewState extends StateMVC<PasswordLoginView> {
  UserController _con;
  _PasswordLoginViewState() : super(UserController()) {
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
            inAsyncCall: _con.showLoader,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: settingRepo.setting.value.bgColor,
//          extendBodyBehindAppBar: true,
                appBar: AppBar(
                  centerTitle: true,
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
                    children: <Widget>[
                      Text(
                        "Login",
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
                        color: settingRepo.setting.value.gridItemBorderColor,
                        height: .4,
                        width: MediaQuery.of(context).size.width * .3,
                      ),
                    ],
                  ),
                ),
                key: _con.userScaffoldKey,
                body: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    color: settingRepo.setting.value.bgColor,
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        color: settingRepo.setting.value.bgColor,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Form(
                                key: _con.registerFormKey,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                          fontWeight: FontWeight.bold,
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
                                        hintText: "Enter Email",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.015,
                                    ),
                                    TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _con.passwordController,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'RockWellStd',
                                        fontSize: 14.0,
                                        color: settingRepo.setting.value.textColor,
                                      ),
                                      /*validator:
                                    _curIndex == 0 ? validateEmail : null,*/
                                      keyboardType: TextInputType.text,
                                      obscureText: true,
                                      onChanged: (String val) {
                                        _con.password = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
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
                                        /*prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.lock_outline_rounded,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Container(
                                          color: Colors.white,
                                          width: 1,
                                          height: 25,
                                        ),
                                      ),
                                    ],
                                  ),*/
                                        contentPadding: EdgeInsets.only(
                                          top: 12,
                                        ),
                                        hintText: "Enter Password",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.05,
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
                                            'Login',
                                            style: TextStyle(
                                              color: settingRepo.setting.value.buttonTextColor,
                                              fontSize: 20,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        _con.login().then(
                                          (value) {
                                            print("value");
                                            print(value);
                                            if (value != null) {
                                              if (value) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => VerifyOTPView(),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ForgotPasswordView(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Forgot Password?",
                                              style: TextStyle(
                                                height: 1.55,
                                                color: settingRepo.setting.value.subHeadingColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
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
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          ],
                        ),
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
