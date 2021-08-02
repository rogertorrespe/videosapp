import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_profile_controller.dart';
import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart';

class BlockedUsers extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int type;
  final int userId;
  BlockedUsers({Key key, this.type, this.userId, this.parentScaffoldKey}) : super(key: key);

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends StateMVC<BlockedUsers> {
  UserProfileController _con;

  int page = 1;
  _BlockedUsersState() : super(UserProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    blockedUsersData = new ValueNotifier(BlockedModel());
    blockedUsersData.notifyListeners();
    _con.getblockedUsers(page);
    super.initState();
  }

  Widget layout(obj) {
    if (obj != null) {
      print(obj);
      if (obj.users.length > 0) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 185,
              child: ListView.builder(
                controller: _con.scrollController,
                padding: EdgeInsets.zero,
                itemCount: obj.users.length,
                itemBuilder: (context, i) {
                  print(obj.users[0].toString());
                  var fullName = obj.users[i].firstName + " " + obj.users[i].lastName;
                  return Container(
                    decoration: new BoxDecoration(
                      border: new Border(bottom: new BorderSide(width: 0.2, color: settingRepo.setting.value.dividerColor)),
                    ),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersProfileView(userId: obj.users[i].id),
                            ),
                          );*/
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: settingRepo.setting.value.dpBorderColor,
                            ),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: (obj.users[i].dp != '')
                                ? CachedNetworkImage(
                                    imageUrl: obj.users[i].dp,
                                    placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                    fit: BoxFit.fill,
                                    width: 50,
                                    height: 50,
                                  )
                                : Image.asset(
                                    'assets/images/default-user.png',
                                    fit: BoxFit.fill,
                                    width: 50,
                                    height: 50,
                                  ),
                          ),
                        ),
                      ),
                      title: GestureDetector(
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersProfileView(userId: obj.users[i].id),
                            ),
                          );*/
                        },
                        child: Text(
                          obj.users[i].username,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      subtitle: Text(
                        fullName,
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      trailing: GestureDetector(
                          onTap: () {
                            if (!_con.blockUnblockLoader) {
                              _con.blockUnblockUser(obj.users[i].id);
                            }
                          },
                          child: Container(
                            width: 85,
                            height: 26,
                            decoration: BoxDecoration(
                              color: settingRepo.setting.value.inactiveButtonColor,
                              border: Border.all(color: settingRepo.setting.value.inactiveButtonColor),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: (!_con.blockUnblockLoader)
                                  ? Text(
                                      "Unblock",
                                      style: TextStyle(
                                        color: (obj.users[i].followText == 'Following') ? settingRepo.setting.value.inactiveButtonTextColor : settingRepo.setting.value.buttonTextColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Helper.showLoaderSpinner(Colors.white),
                            ),
                          )),
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      } else {
        if (!_con.showLoader) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height - 185,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  ),
                  Text(
                    "No Blocked Users",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    } else {
      if (!_con.showLoader) {
        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height - 185,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                ),
                Text(
                  "No User Yet",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                )
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: blockedUsersData,
        builder: (context, BlockedModel _user, _) {
          return ModalProgressHUD(
            inAsyncCall: _con.showLoader,
            progressIndicator: Helper.showLoaderSpinner(Colors.white),
            child: SafeArea(
              child: Scaffold(
                backgroundColor: settingRepo.setting.value.bgColor,
                key: _con.blockedUserScaffoldKey,
                resizeToAvoidBottomInset: false,
                body: SingleChildScrollView(
                  child: Container(
                    color: settingRepo.setting.value.bgColor,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                          child: Container(
                            height: 24,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                    color: settingRepo.setting.value.iconColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        layout(_user),
                        /*SingleChildScrollView(
                          child: Container(
                            //height: MediaQuery.of(context).size.height,
                            child: tabs(_user),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
