import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/following_controller.dart';
import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../repositories/following_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import 'user_profile_view.dart';

class FollowingsView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int type;
  final int userId;
  FollowingsView({Key key, this.type, this.userId, this.parentScaffoldKey}) : super(key: key);

  @override
  _FollowingsViewState createState() => _FollowingsViewState();
}

class _FollowingsViewState extends StateMVC<FollowingsView> {
  FollowingController _con;

  int page = 1;
  _FollowingsViewState() : super(FollowingController()) {
    _con = controller;
  }

  @override
  void initState() {
    usersData = new ValueNotifier(FollowingModel());
    usersData.notifyListeners();
    if (this.widget.type == 0) {
      _con.curIndex = 0;
      _con.followingUsers(widget.userId, page);
    } else {
      _con.curIndex = 1;
      _con.followers(widget.userId, page);
    }
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
                      border: new Border(bottom: new BorderSide(width: 0.2, color: Colors.white)),
                    ),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersProfileView(userId: obj.users[i].id),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersProfileView(userId: obj.users[i].id),
                            ),
                          );
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
                            _con.followUnfollowUser(obj.users[i].id, i);
                          },
                          child: Container(
                            width: 85,
                            height: 26,
                            decoration: (obj.users[i].followText == 'Following')
                                ? BoxDecoration(
                                    color: settingRepo.setting.value.inactiveButtonColor,
                                    border: Border.all(color: settingRepo.setting.value.inactiveButtonColor),
                                    borderRadius: BorderRadius.circular(3),
                                  )
                                : BoxDecoration(
                                    color: settingRepo.setting.value.buttonColor,
                                    border: Border.all(color: settingRepo.setting.value.buttonColor),
                                    borderRadius: BorderRadius.all(
                                      new Radius.circular(5.0),
                                    ),
                                  ),
                            child: Center(
                              child: (!_con.followUnfollowLoader)
                                  ? Text(
                                      obj.users[i].followText,
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
                    "No User Yet",
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

  Widget tabs(user) {
    return DefaultTabController(
      initialIndex: _con.curIndex,
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: TabBar(
              onTap: (index) {
                usersData = new ValueNotifier(FollowingModel());
                usersData.notifyListeners();
                setState(() {
                  _con.searchKeyword = '';
                  _con.curIndex = index;
                  if (index == 0) {
                    _con.followingUsers(widget.userId, 1);
                  } else {
                    _con.followers(widget.userId, 1);
                  }
                });
              },
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Following",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Text(
                        "Followers",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 120,
            child: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
              Container(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      child: TextField(
                        controller: _con.searchController,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16.0,
                        ),
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          setState(() {
                            _con.searchKeyword = val;
                          });
                          Timer(Duration(seconds: 1), () {
                            _con.followingUsers(widget.userId, 1);
                          });
                        },
                        decoration: new InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(fontSize: 16.0, color: Colors.white54),
                          contentPadding: EdgeInsets.fromLTRB(2, 15, 0, 0),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0, right: 0),
                            onPressed: () {
                              _con.searchController.clear();
                              setState(() {
                                _con.searchKeyword = '';
                                _con.followingUsers(widget.userId, 1);
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: (_con.searchKeyword.length > 0) ? settingRepo.setting.value.iconColor : Colors.transparent,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  (user != null) ? layout(user) : Container()
                ],
              )),
              Container(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      child: TextField(
                        controller: _con.searchController,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16.0,
                        ),
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          setState(() {
                            _con.searchKeyword = val;
                          });
                          Timer(Duration(seconds: 1), () {
                            _con.followers(widget.userId, 1);
                          });
                        },
                        decoration: new InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(fontSize: 16.0, color: Colors.white54),
                          contentPadding: EdgeInsets.fromLTRB(2, 15, 0, 0),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0, right: 0),
                            onPressed: () {
                              _con.searchController.clear();
                              setState(() {
                                _con.searchKeyword = '';
                                _con.followers(widget.userId, 1);
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: (_con.searchKeyword.length > 0) ? settingRepo.setting.value.iconColor : Colors.transparent,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  (user != null) ? layout(user) : Container()
                ],
              )),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: usersData,
        builder: (context, FollowingModel _user, _) {
          return ModalProgressHUD(
            inAsyncCall: _con.showLoader,
            progressIndicator: Helper.showLoaderSpinner(Colors.white),
            child: SafeArea(
              child: Scaffold(
                key: _con.scaffoldKey,
                resizeToAvoidBottomInset: false,
                body: SingleChildScrollView(
                  child: Container(
                    color: Color(0XFF15161a),
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
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        SingleChildScrollView(
                          child: Container(
                            //height: MediaQuery.of(context).size.height,
                            child: tabs(_user),
                          ),
                        ),
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
