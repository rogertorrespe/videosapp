import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import 'showCupertinoDatePicker.dart';

class ForgotPasswordView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  ForgotPasswordView({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends StateMVC<ForgotPasswordView> {
  UserController _con;
  int page = 1;
  _ForgotPasswordViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      textAlign: TextAlign.center,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      keyboardType: TextInputType.text,
      controller: _con.emailController,
      onSaved: (String val) {
        _con.email = val;
      },
      onChanged: (String val) {
        _con.email = val;
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
        hintText: "Enter Registered Email",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor.withOpacity(
            0.4,
          ),
        ),
      ),
    );

    return ValueListenableBuilder(
        valueListenable: usersProfileData,
        builder: (context, EditProfileModel _userProfile, _) {
          return SafeArea(
            child: Scaffold(
              key: _con.forgotPasswordScaffoldKey,

              resizeToAvoidBottomInset: false,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(45.0),
                child: AppBar(
                  iconTheme: IconThemeData(
                    color: settingRepo.setting.value.iconColor, //change your color here
                  ),
                  backgroundColor: settingRepo.setting.value.bgColor,
                  title: Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      color: settingRepo.setting.value.textColor,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              body: ModalProgressHUD(
                inAsyncCall: _con.showLoader,
                progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.textColor),
                child: Center(
                    child: Container(
                  color: settingRepo.setting.value.bgColor,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: Container(
                          child: Form(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            key: _con.formKey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                    child: emailField,
                                  ),
                                ),
                                Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: settingRepo.setting.value.dividerColor,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _con.sendPasswordResetOTP();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: settingRepo.setting.value.buttonColor,
                                        ),
                                        height: config.App(context).appWidth(10),
                                        width: config.App(context).appWidth(80),
                                        child: Center(
                                          child: Text(
                                            "Send OTP",
                                            style: TextStyle(
                                              color: settingRepo.setting.value.buttonTextColor,
                                              fontSize: 20,
                                            ),
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
                      ),
                    ],
                  ),
                )),
              ),
            ),
          );
        });
  }
}
