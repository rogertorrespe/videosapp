import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart';
import '../helpers/helper.dart';
import '../models/user_profile_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../views/edit_profile_view.dart';
import '../views/followings.dart';
import '../views/verify_profile.dart';
import 'blocked_users.dart';
import 'change_password_view.dart';
import 'edit_video.dart';

class MyProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  MyProfileView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _MyProfileViewState createState() => _MyProfileViewState();
}

class _MyProfileViewState extends StateMVC<MyProfileView> {
  UserController _con;
  int page = 1;
  _MyProfileViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    // userProfile = new ValueNotifier(UserProfileModel());
    // userProfile.notifyListeners();
    _con.getMyProfile(page);
    print("headingColor");
    print(settingRepo.setting.value.headingColor);
    print("buttonColor");
    print(settingRepo.setting.value.buttonColor);
    super.initState();
  }

  void onSelectedMenu(String choice) {
    if (choice == SettingMenu.LOGOUT) {
      logout().whenComplete(() async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
      });
    } else if (choice == SettingMenu.EDIT_PROFILE) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileView(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyProfileView(),
        ),
      );
    }
  }

  Widget profilePhoto(userProfile) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return Scaffold(
              backgroundColor: settingRepo.setting.value.bgColor,
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
                    color: Colors.white, //change your color here
                  ),
                  // backgroundColor: Color(0xff15161a),
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
              body: Center(
                child: PhotoView(
                  enableRotation: true,
                  imageProvider: CachedNetworkImageProvider((userProfile.largeProfilePic.toLowerCase().contains(".jpg") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".jpeg") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".png") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".gif") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".bmp") ||
                          userProfile.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                          userProfile.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                      ? userProfile.largeProfilePic
                      : '${GlobalConfiguration().getString('base_url')}' + "default/user-dummy-pic.png"),
                ),
              ));
        }));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20,
        ),
        child: Container(
          width: 90.0,
          height: 90.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              100,
            ),
            color: settingRepo.setting.value.dpBorderColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: userProfile.smallProfilePic != null
                      ? CachedNetworkImageProvider((userProfile.smallProfilePic.toLowerCase().contains(".jpg") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".jpeg") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".png") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".gif") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".bmp") ||
                              userProfile.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                              userProfile.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                          ? userProfile.smallProfilePic
                          : '${GlobalConfiguration().getString('base_url')}' + "default/user-dummy-pic.png")
                      : AssetImage('assets/images/default-user.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: new BorderRadius.all(
                  new Radius.circular(
                    100,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget userVideo(userProfile) {
    if (userProfile.userVideos != null) {
      if (userProfile.userVideos.length > 0) {
        var size = MediaQuery.of(context).size;
        final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
        final double itemWidth = size.width / 2;
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: GridView.builder(
            controller: _con.scrollController1,
            // physics: new NeverScrollableScrollPhysics(),
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.all(2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              crossAxisCount: 3,
            ),
            itemCount: userProfile.userVideos.length,
            itemBuilder: (BuildContext context, int i) {
              return GestureDetector(
                onTap: () async {
                  videoRepo.homeCon.value.userVideoObj.value['userId'] = currentUser.value.userId;
                  videoRepo.homeCon.value.userVideoObj.value['videoId'] = userProfile.userVideos[i].videoId;
                  videoRepo.homeCon.value.userVideoObj.notifyListeners();

                  videoRepo.homeCon.value.showFollowingPage.value = false;
                  videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                  videoRepo.homeCon.value.getVideos();
                  Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                },
                child: Container(
                  child: Container(
                    height: size.height,
                    decoration: BoxDecoration(
                      color: settingRepo.setting.value.bgColor,
                      borderRadius: BorderRadius.circular(settingRepo.setting.value.gridBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: settingRepo.setting.value.gridItemBorderColor,
                          blurRadius: 3.0, // soften the shadow
                          spreadRadius: 0.0, //extend the shadow
                          offset: Offset(
                            0.0, // Move to right 10  horizontally
                            0.0, // Move to bottom 5 Vertically
                          ),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 7,
                        ),
                        Expanded(
                          child: Center(
                            child: userProfile.userVideos[i].videoThumbnail != ""
                                ? Container(
                                    constraints: BoxConstraints(
                                      maxHeight: size.height - (32),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: userProfile.userVideos[i].videoThumbnail,
                                      placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/noVideo.jpg',
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        Center(
                          child: Container(
                            height: 25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 13,
                                          color: settingRepo.setting.value.iconColor,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          userProfile.userVideos[i].totalLikes.toString(),
                                          style: TextStyle(fontSize: 11, color: settingRepo.setting.value.textColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.remove_red_eye,
                                          size: 13,
                                          color: settingRepo.setting.value.iconColor,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          Helper.formatter(userProfile.userVideos[i].totalViews.toString()),
                                          style: TextStyle(fontSize: 11, color: settingRepo.setting.value.textColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: PopupMenuButton<int>(
                                    padding: EdgeInsets.only(bottom: 0, left: 10),
                                    color: settingRepo.setting.value.buttonColor,
                                    icon: Icon(
                                      Icons.more_vert,
                                      size: 18,
                                      color: settingRepo.setting.value.iconColor,
                                    ),
                                    onSelected: (int) {
                                      if (int == 0) {
                                        //edit
                                        print("Edit Video");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditVideo(video: userProfile.userVideos[i]),
                                          ),
                                        );
                                      } else {
                                        //Delete
                                        print("Delete Video");
                                        _con.showDeleteAlert(
                                            "Delete Confirmation", "Do you realy want to delete the video", userProfile.userVideos[i].videoId);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        height: 15,
                                        value: 0,
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: settingRepo.setting.value.buttonTextColor,
                                            // fontFamily: 'RockWellStd',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        height: 15,
                                        value: 1,
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: settingRepo.setting.value.buttonTextColor,
                                            // fontFamily: 'RockWellStd',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        if (!_con.showLoader) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.videocam,
                    size: 30,
                    color: Colors.grey,
                  ),
                  Text(
                    "No Videos Yet",
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
    } else {
      if (!_con.showLoader) {
        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.videocam,
                  size: 30,
                  color: Colors.grey,
                ),
                Text(
                  "No Videos Yet",
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

  Widget tabs(userProfile) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0),
      child: DefaultTabController(
        length: 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _con.curIndex = index;
                  });
                },
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                indicatorWeight: 0.2,
                labelPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          (0 == 0)
                              ? Icon(
                                  Icons.videocam,
                                  size: 35,
                                  color: settingRepo.setting.value.iconColor,
                                )
                              : Image.asset('assets/icons/my-video-d.png', width: 35),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "User Videos",
                            style: TextStyle(color: settingRepo.setting.value.subHeadingColor, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 440,
              child: TabBarView(children: [
                Container(child: userVideo(userProfile)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget profilePersonInfo(userProfile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        20,
        0,
        0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            userProfile.name != null ? userProfile.name : '',
            style: TextStyle(
              color: settingRepo.setting.value.headingColor,
              fontSize: 18,
              /* fontFamily: 'RockWellStd',*/ fontWeight: FontWeight.w500,
            ),
            // style: TextStyle(color: Color(0xfff5ae78), fontSize: 15, fontFamily: 'RockWellStd', fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                ),
                child: Text(
                  userProfile.username != null ? userProfile.username : '',
                  style: TextStyle(
                      color: settingRepo.setting.value.subHeadingColor, fontSize: 14, fontFamily: 'RockWellStd', fontWeight: FontWeight.w500),
                ),
              ),
              userProfile.isVerified == true
                  ? Icon(
                      Icons.verified,
                      color: Colors.blueAccent,
                      size: 16,
                    )
                  : Container(),
            ],
          ),
          Container(
            child: Text(
              userProfile.bio,
              style: TextStyle(
                color: settingRepo.setting.value.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      key: _con.myProfileScaffoldKey,
      body: WillPopScope(
        onWillPop: () async {
          if (videoRepo.homeCon.value.showFollowingPage.value) {
            await videoRepo.homeCon.value.getFollowingUserVideos();
          } else {
            await videoRepo.homeCon.value.getVideos();
          }
          videoRepo.homeCon.notifyListeners();
          Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
          return Future.value(true);
        },
        child: ValueListenableBuilder(
            valueListenable: myProfile,
            builder: (context, UserProfileModel userProfile, _) {
              return ModalProgressHUD(
                color: settingRepo.setting.value.accentColor,
                inAsyncCall: _con.showLoader,
                progressIndicator: Helper.showLoaderSpinner(Colors.white),
                child: SafeArea(
                  child: Scaffold(
                    endDrawer: Container(
                      width: 250,
                      child: Drawer(
//                      elevation: 1,
                        // Add a ListView to the drawer. This ensures the user can scroll
                        // through the options in the drawer if there isn't enough vertical
                        // space to fit everything.
                        child: Stack(
                          children: [
                            Container(
                              color: settingRepo.setting.value.accentColor,
                              child: ListView(
                                // Important: Remove any padding from the ListView.
                                padding: EdgeInsets.zero,
                                children: <Widget>[
                                  Container(
                                    height: 70.0,
                                    child: DrawerHeader(
                                      child: Text(
                                        'Settings',
                                        style: TextStyle(color: settingRepo.setting.value.headingColor),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0XFF15161a).withOpacity(0.1),
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 0.5,
                                            color: settingRepo.setting.value.dividerColor,
                                          ),
                                        ),
                                      ),
                                      margin: EdgeInsets.all(0.0),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    // contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.person,
                                      color: settingRepo.setting.value.iconColor,
                                    ),
                                    title: Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: settingRepo.setting.value.textColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProfileView(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.verified_user,
                                      color: settingRepo.setting.value.iconColor,
                                    ),
                                    title: Text(
                                      'Verification',
                                      style: TextStyle(
                                        color: settingRepo.setting.value.textColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VerifyProfileView(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.block,
                                      color: settingRepo.setting.value.iconColor,
                                    ),
                                    title: Text(
                                      'Blocked Users',
                                      style: TextStyle(
                                        color: settingRepo.setting.value.textColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BlockedUsers(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.lock,
                                      color: settingRepo.setting.value.iconColor,
                                    ),
                                    title: Text(
                                      'Change Password',
                                      style: TextStyle(
                                        color: settingRepo.setting.value.textColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChangePasswordView(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.logout,
                                      color: settingRepo.setting.value.iconColor,
                                      textDirection: TextDirection.rtl,
                                    ),
                                    title: Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: settingRepo.setting.value.textColor,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      logout().whenComplete(() async {
                                        videoRepo.homeCon.value.showFollowingPage.value = false;
                                        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                        videoRepo.homeCon.value.getVideos();
                                        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: 250,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "App Version  ${userProfile.appVersion}",
                                      style: TextStyle(
                                        color: settingRepo.setting.value.textColor,
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
                    key: _con.userScaffoldKey,
                    backgroundColor: settingRepo.setting.value.bgColor,
                    resizeToAvoidBottomInset: false,
                    body: RefreshIndicator(
                      backgroundColor: settingRepo.setting.value.buttonColor,
                      color: settingRepo.setting.value.buttonTextColor,
                      onRefresh: _con.refreshMyProfile,
                      child: SingleChildScrollView(
                        child: Container(
                          color: settingRepo.setting.value.bgColor,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                                child: Container(
                                  height: 24,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () async {
                                          videoRepo.homeCon.value.showFollowingPage.value = false;
                                          videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                          videoRepo.homeCon.value.getVideos();
                                          Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                        },
                                        child: Icon(Icons.arrow_back_ios, size: 20, color: settingRepo.setting.value.iconColor),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width - 88,
                                      ),
                                      InkWell(
                                          child: Icon(
                                            Icons.settings,
                                            size: 22,
                                            color: settingRepo.setting.value.iconColor,
                                          ),
                                          onTap: () {
                                            _con.userScaffoldKey.currentState.openEndDrawer();
                                          }),
                                      // PopupMenuButton<String>(
                                      //   icon: Icon(Icons.settings, size: 22, color: Colors.white),
                                      //   onSelected: onSelectedMenu,
                                      //   color: Color(0xff444549),
                                      //   itemBuilder: (BuildContext context) {
                                      //     return SettingMenu.choices.map((String choice) {
                                      //       return PopupMenuItem(
                                      //         height: 30,
                                      //         value: choice,
                                      //         child: Text(
                                      //           choice,
                                      //           style: TextStyle(
                                      //             color: Colors.white,
                                      //             fontFamily: 'RockWellStd',
                                      //             fontSize: 15,
                                      //           ),
                                      //         ),
                                      //       );
                                      //     }).toList();
                                      //   },
                                      // )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                child: Container(
                                  // height: 180,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      userProfile != null
                                          ? profilePhoto(userProfile)
                                          : SizedBox(
                                              height: 0,
                                            ),
                                      userProfile != null
                                          ? profilePersonInfo(userProfile)
                                          : SizedBox(
                                              height: 0,
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      // color: Color(0xff15161a),
                                      // padding: EdgeInsets.all(0),
                                      child: Container(
                                        height: App(context).appHeight(4),
                                        width: App(context).appWidth(45),
                                        color: settingRepo.setting.value.buttonColor,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                "Edit Profile",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.buttonTextColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  fontFamily: 'RockWellStd',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditProfileView(),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      // color: Color(0xff15161a),
                                      // padding: EdgeInsets.all(0),
                                      child: Container(
                                        height: App(context).appHeight(4),
                                        width: App(context).appWidth(45),
                                        color: settingRepo.setting.value.buttonColor,
                                        // decoration: BoxDecoration(gradient: Gradients.blush),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                "My Chat",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.buttonTextColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  fontFamily: 'RockWellStd',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/user-chats",
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3, bottom: 3),
                                            child: Text(
                                              userProfile.totalVideos != null ? userProfile.totalVideos.toString() : '',
                                              style: TextStyle(
                                                color: settingRepo.setting.value.textColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "POSTS",
                                            style: TextStyle(
                                              color: settingRepo.setting.value.subHeadingColor,
                                              fontSize: 11,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      width: 0.8,
                                      color:
                                          settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3, bottom: 3),
                                            child: Text(
                                              userProfile.totalVideosLike != null ? userProfile.totalVideosLike : '',
                                              style: TextStyle(
                                                color: settingRepo.setting.value.textColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "LIKES",
                                            style: TextStyle(
                                              color: settingRepo.setting.value.subHeadingColor,
                                              fontSize: 11,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      width: 0.8,
                                      color:
                                          settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () {
                                          if (userProfile.totalFollowers != '0') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FollowingsView(userId: userRepo.currentUser.value.userId, type: 1),
                                              ),
                                            );
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(top: 3, bottom: 3),
                                              child: Text(
                                                userProfile.totalFollowers != null ? userProfile.totalFollowers : '',
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.textColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "FOLLOWERS",
                                              style: TextStyle(
                                                color: settingRepo.setting.value.subHeadingColor,
                                                fontSize: 11,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      width: 0.8,
                                      color:
                                          settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () {
                                          if (userProfile.totalFollowings != '0') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FollowingsView(userId: userRepo.currentUser.value.userId, type: 0),
                                              ),
                                            );
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(top: 3, bottom: 3),
                                              child: Text(
                                                userProfile.totalFollowings != null ? userProfile.totalFollowings : '',
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.textColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (userProfile.totalFollowings != '0') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => FollowingsView(type: 0),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                "FOLLOWING",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.subHeadingColor,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: settingRepo.setting.value.dividerColor != null
                                            ? settingRepo.setting.value.dividerColor
                                            : Colors.grey[400],
                                        width: 0.4)),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Container(
                                child: tabs(userProfile),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class SettingMenu {
  static const String LOGOUT = 'Logout';
  static const String EDIT_PROFILE = 'Edit Profile';
  static const String VERIFY = 'Verification';
  static const List<String> choices = <String>[EDIT_PROFILE, VERIFY, LOGOUT];
}
