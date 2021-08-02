import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/user_profile_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart';
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../widgets/AdsWidget.dart';
import 'chat.dart';
import 'followings.dart';
import 'login_view.dart';

class UsersProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int userId;
  UsersProfileView({Key key, this.userId, this.parentScaffoldKey}) : super(key: key);

  @override
  _UsersProfileViewState createState() => _UsersProfileViewState();
}

class _UsersProfileViewState extends StateMVC<UsersProfileView> {
  UserController _con;
  _UsersProfileViewState() : super(UserController()) {
    _con = controller;
  }

  int page = 1;
  @override
  void initState() {
    // userProfile = new ValueNotifier(UserProfileModel());
    // userProfile.notifyListeners();

    _con.getUsersProfile(widget.userId, page);
    _con.getAds();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget profilePhoto(userProfile) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Scaffold(
                key: _con.myProfileScaffoldKey,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(45.0),
                  child: AppBar(
                    leading: InkWell(
                      onTap: () async {
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
                    backgroundColor: settingRepo.setting.value.bgColor.withOpacity(0.60),
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
                backgroundColor: settingRepo.setting.value.bgColor.withOpacity(0.60),
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
                ),
              );
            },
          ),
        );
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
                borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
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
            padding: const EdgeInsets.all(2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              crossAxisCount: 3,
            ),
            itemCount: userProfile.userVideos.length,
            itemBuilder: (BuildContext context, int i) {
              return /*AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 300),
                child: SlideAnimation(
                  verticalOffset: 20.0,
                  child: FadeInAnimation(
                    child: */
                  GestureDetector(
                onTap: () async {
                  videoRepo.homeCon.value.userVideoObj.value['userId'] = userProfile.userVideos[i].userId;
                  videoRepo.homeCon.value.userVideoObj.value['videoId'] = userProfile.userVideos[i].videoId;
                  videoRepo.homeCon.value.userVideoObj.value['name'] = userProfile.name.split(" ").first + "'s";
                  videoRepo.homeCon.value.showFollowingPage.value = false;
                  videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                  videoRepo.homeCon.value.getVideos().whenComplete(() {
                    videoRepo.homeCon.notifyListeners();
                    Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                  });
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
                                ? CachedNetworkImage(
                                    imageUrl: userProfile.userVideos[i].videoThumbnail,
                                    placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                    fit: BoxFit.fitHeight,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: settingRepo.setting.value.textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: settingRepo.setting.value.textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
        mainAxisAlignment: MainAxisAlignment.start,
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
            padding: EdgeInsets.symmetric(
              vertical: 10,
            ),
            width: config.App(context).appWidth(70),
            child: Text(
              userRepo.userProfile.value.bio,
              style: TextStyle(
                color: settingRepo.setting.value.textColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
      child: Stack(
        children: [
          ValueListenableBuilder(
              valueListenable: userProfile,
              builder: (context, UserProfileModel _userProfile, _) {
                return ModalProgressHUD(
                  inAsyncCall: _con.showLoader,
                  progressIndicator: Helper.showLoaderSpinner(Colors.white),
                  child: SafeArea(
                    child: Scaffold(
                      key: _con.userScaffoldKey,
                      resizeToAvoidBottomInset: false,
                      body: RefreshIndicator(
                        backgroundColor: settingRepo.setting.value.buttonColor,
                        color: settingRepo.setting.value.buttonTextColor,
                        onRefresh: _con.refreshUserProfile,
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () async {
                                            videoRepo.homeCon.value.showFollowingPage.value = false;
                                            videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                            Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                            videoRepo.homeCon.value.getVideos();
                                          },
                                          child: Icon(Icons.arrow_back_ios, size: 20, color: settingRepo.setting.value.iconColor),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * .78,
                                        ),
                                        currentUser.value.token != null
                                            ? PopupMenuButton<int>(
                                                color: settingRepo.setting.value.buttonColor,
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  size: 22,
                                                  color: settingRepo.setting.value.iconColor,
                                                ),
                                                onSelected: (int) {
                                                  _con.blockUser(widget.userId);
                                                },
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    height: 20,
                                                    value: 1,
                                                    child: Text(
                                                      _userProfile.blocked == 'yes' ? 'Unblock' : 'Block',
                                                      style: TextStyle(
                                                        color: settingRepo.setting.value.buttonTextColor,
                                                        fontFamily: 'RockWellStd',
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
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
                                        /*Expanded(
                                          child: */
                                        _userProfile != null
                                            ? profilePhoto(_userProfile)
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        /*),*/
                                        _userProfile != null
                                            ? profilePersonInfo(_userProfile)
                                            : SizedBox(
                                                height: 0,
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                userRepo.currentUser.value.userId != widget.userId
                                    ? Padding(
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
                                                  child: (!_con.followUnfollowLoader)
                                                      ? Text(
                                                          _userProfile.followText != null ? _userProfile.followText : "Follow",
                                                          style: TextStyle(
                                                            color: settingRepo.setting.value.buttonTextColor,
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 14,
                                                            fontFamily: 'RockWellStd',
                                                          ),
                                                        )
                                                      : Helper.showLoaderSpinner(Colors.white),
                                                ),
                                              ),
                                              onTap: () {
                                                if (currentUser.value.token == null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LoginPageView(userId: widget.userId),
                                                    ),
                                                  );
                                                } else {
                                                  _con.followUnfollowUserFromUserProfile(widget.userId);
                                                }
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
                                                  child: Text(
                                                    "Chat",
                                                    style: TextStyle(
                                                      color: settingRepo.setting.value.buttonTextColor,
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 14,
                                                      fontFamily: 'RockWellStd',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                if (currentUser.value.token == null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LoginPageView(userId: widget.userId),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ChatView(
                                                        userId: widget.userId,
                                                        userName: _userProfile.username,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
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
                                                _userProfile.totalVideos != null ? _userProfile.totalVideos.toString() : '',
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
                                        color: settingRepo.setting.value.dividerColor != null
                                            ? settingRepo.setting.value.dividerColor
                                            : Colors.grey[400],
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
                                                _userProfile.totalVideosLike != null ? _userProfile.totalVideosLike : '',
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
                                        color: settingRepo.setting.value.dividerColor != null
                                            ? settingRepo.setting.value.dividerColor
                                            : Colors.grey[400],
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            if (_userProfile.totalFollowers != '0') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FollowingsView(userId: widget.userId, type: 1),
                                                ),
                                              );
                                            }
                                          },
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3, bottom: 3),
                                                child: Text(
                                                  _userProfile.totalFollowers != null ? _userProfile.totalFollowers : '',
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 0.8,
                                        color: settingRepo.setting.value.dividerColor != null
                                            ? settingRepo.setting.value.dividerColor
                                            : Colors.grey[400],
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            if (_userProfile.totalFollowings != '0') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FollowingsView(userId: widget.userId, type: 0),
                                                ),
                                              );
                                            }
                                          },
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3, bottom: 3),
                                                child: Text(
                                                  _userProfile.totalFollowings != null ? _userProfile.totalFollowings : '',
                                                  style: TextStyle(
                                                    color: settingRepo.setting.value.textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "FOLLOWING",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.subHeadingColor,
                                                  fontSize: 11,
                                                ),
                                              ),
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
                                      color: settingRepo.setting.value.dividerColor,
                                      width: 0.4,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                SingleChildScrollView(
                                  child: Container(
                                    child: tabs(_userProfile),
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
              }),
          Positioned(
            bottom: Platform.isAndroid ? 0 : 15,
            child: ValueListenableBuilder(
              valueListenable: _con.showBannerAd,
              builder: (context, adLoader, _) {
                return adLoader
                    ? Center(child: Container(width: MediaQuery.of(context).size.width, child: BannerAdWidget(AdSize.banner)))
                    : Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
