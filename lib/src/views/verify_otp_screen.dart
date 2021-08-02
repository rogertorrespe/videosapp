import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/user_controller.dart';
import '../repositories/settings_repository.dart' as settingRepo;

class VerifyOTPView extends StatefulWidget {
  VerifyOTPView();
  @override
  _VerifyOTPViewState createState() => _VerifyOTPViewState();
}

class _VerifyOTPViewState extends StateMVC<VerifyOTPView> {
  ScaffoldState scaffold;
  UserController _con;
  _VerifyOTPViewState() : super(UserController()) {
    _con = controller;
  }
  TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  StreamController<ErrorAnimationType> errorController;
  @override
  void initState() {
    _con.startTimer();
    setState(() {
      _con.bHideTimer = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      extendBodyBehindAppBar: true,
      key: _con.otpScaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: settingRepo.setting.value.iconColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: ModalProgressHUD(
        progressIndicator: _con.showLoaderSpinner(),
        inAsyncCall: _con.showLoader,
        opacity: 1.0,
        color: Colors.black26,
        child: Container(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Form(
            key: _con.otpFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.022,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Text(
                          "Email Verification",
                          style: TextStyle(
                            color: settingRepo.setting.value.textColor,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'QueenCamelot',
                            fontSize: 38,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .005,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .020,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * .015),
                      Stack(
                        children: <Widget>[
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: MediaQuery.of(context).size.height * 0.037),
                                Padding(
                                  padding: EdgeInsets.only(left: 3.5),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "OTP sent to your registered Email ID",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: settingRepo.setting.value.textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      Container(
                                        color: Colors.black,
                                        height: MediaQuery.of(context).size.height / 12,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                                            child: PinCodeTextField(
                                              backgroundColor: settingRepo.setting.value.bgColor,
                                              appContext: context,
                                              pastedTextStyle: TextStyle(
                                                color: Colors.green.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              length: 6,
                                              obscureText: true,
                                              obscuringCharacter: '*',
                                              blinkWhenObscuring: true,
                                              animationType: AnimationType.fade,
                                              pinTheme: PinTheme(
                                                inactiveColor: Colors.white,
                                                disabledColor: Colors.white,
                                                inactiveFillColor: Colors.white,
                                                selectedFillColor: Colors.white,
                                                shape: PinCodeFieldShape.box,
                                                borderRadius: BorderRadius.circular(5),
                                                fieldHeight: 50,
                                                fieldWidth: 40,
                                                activeFillColor: hasError ? settingRepo.setting.value.textColor : settingRepo.setting.value.textColor,
                                              ),
                                              cursorColor: Colors.black,
                                              animationDuration: Duration(milliseconds: 300),
                                              enableActiveFill: true,
                                              errorAnimationController: errorController,
                                              controller: textEditingController,
                                              keyboardType: TextInputType.number,
                                              boxShadows: [
                                                BoxShadow(
                                                  offset: Offset(0, 1),
                                                  color: settingRepo.setting.value.bgColor,
                                                  blurRadius: 10,
                                                )
                                              ],
                                              onCompleted: (v) {
                                                setState(() {
                                                  _con.otp = v;
                                                });
                                              },
                                              onChanged: (value) {
                                                print(value);
                                                setState(() {
                                                  _con.otp = value;
                                                });
                                              },
                                              beforeTextPaste: (text) {
                                                print("Allowing to paste $text");
                                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                                return true;
                                              },
                                            ),
                                          ),

                                          // child: PinEntryTextField(
                                          //   fields: 6,
                                          //   fieldWidth: MediaQuery.of(context).size.width / 10,
                                          //   fontSize: 30.0,
                                          //   isTextObscure: true,
                                          //   showFieldAsBox: true,
                                          //   onSubmit: (String pin) {
                                          //     _con.otp = pin;
                                          //     // _validate = true;
                                          //   }, // end onSubmit
                                          // ), // end Padding()
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * .03),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 30,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        (_con.bHideTimer)
                            ? Text(
                                'Resend OTP in ${_con.countTimer} seconds',
                                style: TextStyle(
                                  color: settingRepo.setting.value.headingColor,
                                  fontSize: 20,
                                  fontFamily: 'RockWellStd',
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : Column(
                                children: <Widget>[
                                  Text(
                                    "Did not get OTP?",
                                    style: TextStyle(
                                      color: settingRepo.setting.value.textColor,
                                      fontSize: 17,
                                      fontFamily: 'RockWellStd',
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _con.resendOtp(verifyPage: true);
                                    },
                                    child: Text(
                                      "Click here to resend OTP",
                                      style: TextStyle(color: settingRepo.setting.value.headingColor, fontSize: 17, fontFamily: 'RockWellStd', fontWeight: FontWeight.w400),
                                    ),
                                  )
                                ],
                              )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                GestureDetector(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: settingRepo.setting.value.buttonColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: Text(
                      "Login Now",
                      style: TextStyle(
                        color: settingRepo.setting.value.buttonTextColor,
                        fontSize: 20.0,
                      ),
                    )),
                  ),
                  onTap: () async {
                    _con.verifyOtp();
                    FocusScope.of(context).unfocus();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
