import 'package:Leuke/src/helpers/app_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/login_view.dart';
import '../views/my_profile_view.dart';
import '../views/user_profile_view.dart';

class VideoDescription extends StatefulWidget {
  final Video video;
  final PanelController pc3;
  VideoDescription(this.video, this.pc3);
  @override
  _VideoDescriptionState createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends StateMVC<VideoDescription> {
  String username = "";
  String description = "";
  String appToken = "";
  int soundId = 0;
  int loginId = 0;
  bool isLogin = false;
  AnimationController animationController;
  // static const double ActionWidgetSize = 60.0;
  // static const double ProfileImageSize = 50.0;

  String soundImageUrl;

  String profileImageUrl = "";

  bool showFollowLoader = false;
  bool isVerified = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.video.username;
    isVerified = widget.video.isVerified;
    // isVerified = true;
    description = widget.video.description;
    profileImageUrl = widget.video.userDP;
    print("CheckVerified $username ${widget.video.isVerified};");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
/*
  _getSessionData() async {
    sessions.getUserInfo().then((obj) {
      setState(() {
        if (obj['user_id'] > 0) {
          isLogin = true;
          loginId = obj['user_id'];
          appToken = obj['app_token'];
        } else {}
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: App(context).appHeight(40),
        ),
        padding: EdgeInsets.only(left: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    if (!videoRepo.homeCon.value.showFollowingPage.value) {
                      videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                    } else {
                      videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                    }
                    videoRepo.isOnHomePage.value = false;
                    videoRepo.isOnHomePage.notifyListeners();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => widget.video.userId == userRepo.currentUser.value.userId
                            ? MyProfileView()
                            : UsersProfileView(
                                userId: widget.video.userId,
                              ),
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
                    child: profileImageUrl != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: CachedNetworkImage(
                              imageUrl: profileImageUrl,
                              placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.iconColor),
                              height: 60.0,
                              width: 60.0,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image.asset(
                              "assets/images/splash.png",
                              height: 40.0,
                              width: 40.0,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    username != ''
                        ? GestureDetector(
                            onTap: () async {
                              /*await videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                              await videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();*/
                              videoRepo.isOnHomePage.value = false;
                              videoRepo.isOnHomePage.notifyListeners();
                              if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                              } else {
                                videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                              }
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => widget.video.userId == userRepo.currentUser.value.userId
                                      ? MyProfileView()
                                      : UsersProfileView(
                                          userId: widget.video.userId,
                                        ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: settingRepo.setting.value.headingColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                isVerified == true
                                    ? Icon(
                                        Icons.verified,
                                        color: Colors.blueAccent,
                                        size: 16,
                                      )
                                    : Container(),
                                SizedBox(
                                  width: 20.0,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    (widget.video.userId != userRepo.currentUser.value.userId)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                showFollowLoader == true
                                    ? Helper.showLoaderSpinner(Colors.black)
                                    : InkWell(
                                        onTap: () async {
                                          if (userRepo.currentUser.value.token != null) {
                                            if (mounted)
                                              setState(() {
                                                showFollowLoader = true;
                                              });
                                            if (videoRepo.homeCon.value.showFollowingPage.value) {
                                              if (videoRepo.followingUsersVideoData.value.videos
                                                      .elementAt(videoRepo.homeCon.value.showFollowingPage.value ? videoRepo.homeCon.value.swiperIndex2 : videoRepo.homeCon.value.swiperIndex)
                                                      .isFollowing ==
                                                  0) {
                                                videoRepo.followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex2).totalFollowers++;
                                              } else {
                                                videoRepo.followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex2).totalFollowers--;
                                              }
                                              videoRepo.followingUsersVideoData.notifyListeners();
                                            } else {
                                              if (videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).isFollowing == 0) {
                                                videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).totalFollowers++;
                                              } else {
                                                videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).totalFollowers--;
                                              }
                                              videoRepo.videosData.notifyListeners();
                                            }

                                            videoRepo.homeCon.value.followUnfollowUser(widget.video).then((value) {
                                              print("complete follow");
                                              // if (mounted)
                                              setState(() {
                                                showFollowLoader = false;
                                              });
                                            });
                                          } else {
                                            // await videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                            // await videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                            videoRepo.isOnHomePage.value = false;
                                            videoRepo.isOnHomePage.notifyListeners();
                                            if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                            } else {
                                              videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                            }
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LoginPageView(userId: 0),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 25,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            color: settingRepo.setting.value.buttonColor,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Center(
                                            child: (!videoRepo.homeCon.value.followUnfollowLoader)
                                                ? videoRepo.homeCon.value.showFollowingPage.value
                                                    ? Text(
                                                        (videoRepo.followingUsersVideoData.value.videos
                                                                    .elementAt(
                                                                        videoRepo.homeCon.value.showFollowingPage.value ? videoRepo.homeCon.value.swiperIndex2 : videoRepo.homeCon.value.swiperIndex)
                                                                    .isFollowing ==
                                                                0)
                                                            ? "Follow"
                                                            : "Unfollow",
                                                        style: TextStyle(
                                                          color: settingRepo.setting.value.buttonTextColor,
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    : Text(
                                                        (videoRepo.videosData.value.videos
                                                                    .elementAt(
                                                                        videoRepo.homeCon.value.showFollowingPage.value ? videoRepo.homeCon.value.swiperIndex2 : videoRepo.homeCon.value.swiperIndex)
                                                                    .isFollowing ==
                                                                0)
                                                            ? "Follow"
                                                            : "Unfollow",
                                                        style: TextStyle(
                                                          color: settingRepo.setting.value.buttonTextColor,
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                : showLoaderSpinner(),
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "${Helper.formatter(widget.video.totalFollowers.toString())} Followers",
                                  style: TextStyle(
                                    color: settingRepo.setting.value.textColor,
                                    fontSize: 12,
                                  ),
                                )
                                // SizedBox(
                                //   width: 55.0,
                                // ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            description != ''
                ? /*Expanded(
                    flex: 4,*/
                Container(
                    constraints: BoxConstraints(
                      maxHeight: App(context).appHeight(40) - 80,
                    ),
                    child: new SingleChildScrollView(
                      scrollDirection: Axis.vertical, //.horizontal
                      child: Text(
                        description,
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                        ),
                      ),
                    ),
                  )
                : Container(),
            // SizedBox(
            //   width: 30.0,
            // ),
            /*SizedBox(
              width: 150.0,
              child: MarqueeWidget(
                direction: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.video.soundTitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

/*  Widget _getMusicPlayerAction() {
    return GestureDetector(
      onTap: () {
        print(soundId);
        (isLogin)
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoRecorder(soundId),
                ),
              )
            : widget.pc3.open();
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(animationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: ActionWidgetSize,
          height: ActionWidgetSize,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                height: ProfileImageSize,
                width: ProfileImageSize,
                decoration: BoxDecoration(
                  gradient: musicGradient,
                  borderRadius: BorderRadius.circular(ProfileImageSize / 2),
                ),
                child: Container(
                  height: 45.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(50),
                    image: new DecorationImage(
                      image: new CachedNetworkImageProvider(soundImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/
  static showLoaderSpinner() {
    return Center(
      child: Container(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  LinearGradient get musicGradient =>
      LinearGradient(colors: [Colors.grey[800], Colors.grey[900], Colors.grey[900], Colors.grey[800]], stops: [0.0, 0.4, 0.6, 1.0], begin: Alignment.bottomLeft, end: Alignment.topRight);
}
