import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;

class EditVideo extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final Video video;

  EditVideo({@required this.video, this.parentScaffoldKey}) : assert(video != null);
  @override
  _EditVideoState createState() => _EditVideoState();
}

class _EditVideoState extends StateMVC<EditVideo> with SingleTickerProviderStateMixin {
  UserController _con;
  _EditVideoState() : super(UserController()) {
    _con = controller;
  }
  AnimationController animationController;

  @override
  void initState() {
    print("thumbImg ${widget.video.videoThumbnail}");
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    setState(() {
      _con.description = widget.video.description;
                                            _con.privacy = widget.video.privacy;
      _con.descriptionTextController = new TextEditingController(text: Helper.removeAllHtmlTags(widget.video.description));
    });

    super.initState();
  }

  bool fitHeight = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _con.showLoader,
      progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor),
      child: Scaffold(
        backgroundColor: settingRepo.setting.value.bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: settingRepo.setting.value.bgColor,
          elevation: 1.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: settingRepo.setting.value.textColor,
              size: 25,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Edit Post',
            style: TextStyle(color: settingRepo.setting.value.headingColor),
          ),
        ),
        key: _con.editVideoScaffoldKey,
        body: SingleChildScrollView(
          child: publishPanel(),
        ),
      ),
    );
  }

  Widget publishPanel() {
    const Map<String, int> privacies = {'Public': 0, 'Private': 1, 'Only Followers': 2};

    return Stack(
      children: [
        Column(
          children: [
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                color: settingRepo.setting.value.bgColor,
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: _con.editVideoFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 7.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          height: 1,
                          child: Container(
                            color: Colors.white30,
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .1, vertical: 0),
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  controller: _con.descriptionTextController,
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: settingRepo.setting.value.textColor,
                                  ),
                                  validator: _con.validateDescription,
                                  onSaved: (String val) {
                                    _con.description = val;
                                  },
                                  onChanged: (String val) {
                                    _con.description = val;
                                  },
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      wordSpacing: 2.0,
                                    ),
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: settingRepo.setting.value.dividerColor),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: settingRepo.setting.value.dividerColor,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: settingRepo.setting.value.dividerColor,
                                        width: 1,
                                      ),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                    hintText: "Enter Video Description",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Container(
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Colors.black,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.lock_outline,
                                                color: settingRepo.setting.value.iconColor,
                                                size: 22,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                "Privacy Setting",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.textColor,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * .4,
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
//                                      canvasColor: Color(0xffffffff),
                                                canvasColor: Colors.black87,
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField(
                                                  isExpanded: true,
                                                  hint: new Text(
                                                    "Select Type",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                  ),
                                                  iconEnabledColor: Colors.white,
                                                  style: new TextStyle(
                                                    color: settingRepo.setting.value.textColor,
                                                    fontSize: 15.0,
                                                  ),
                                                  value: widget.video.privacy,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      _con.privacy = newValue;
                                                    });
                                                  },
                                                  items: privacies
                                                      .map((text, value) {
                                                        return MapEntry(
                                                          text,
                                                          DropdownMenuItem<int>(
                                                            value: value,
                                                            child: new Text(
                                                              text,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: settingRepo.setting.value.textColor,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                      .values
                                                      .toList(),
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
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: FlatButton(
                                      color: Colors.transparent,
                                      padding: EdgeInsets.all(10),
                                      child: Container(
                                        height: 45,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          color: settingRepo.setting.value.buttonColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: settingRepo.setting.value.buttonTextColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 20,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        // Validate returns true if the form is valid, otherwise false.
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: FlatButton(
                                      color: Colors.transparent,
                                      padding: EdgeInsets.all(10),
                                      child: Container(
                                        height: 45,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          color: settingRepo.setting.value.buttonColor,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Update",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.buttonTextColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 20,
                                                  fontFamily: 'RockWellStd',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        FocusManager.instance.primaryFocus.unfocus();

                                        // Validate returns true if the form is valid, otherwise false.
                                        if (_con.editVideoFormKey.currentState.validate()) {
                                          // If the form is valid, display a snackbar. In the real world,
                                          // you'd often call a server or save the information in a database.
                                          // _con.enableVideo(context);
                                          _con.editVideo(
                                            widget.video.videoId,
                                            _con.description,
                                            _con.privacy,
                                          );
                                        } else {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              behavior: SnackBarBehavior.floating,
                                              content: Text("Enter Video Description"),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
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
      ],
    );
  }
}
