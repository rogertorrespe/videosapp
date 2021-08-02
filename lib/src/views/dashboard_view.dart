import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Leuke/src/widgets/AdsWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:share/share.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/dashboard_controller.dart';
import '../helpers/helper.dart';
import '../models/sound_model.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/sound_repository.dart' as soundRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../repositories/video_repository.dart';
import '../views/login_view.dart';
import '../widgets/VideoDescription.dart';
import '../widgets/VideoPlayer.dart';
import 'my_profile_view.dart';
import 'user_profile_view.dart';

class DashboardWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  // final DashboardController con;
  DashboardWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends StateMVC<DashboardWidget> with SingleTickerProviderStateMixin, RouteAware {
  DashboardController _con;
  double hgt = 0;
  AnimationController musicAnimationController;
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != videoRepo.homeCon.value.textFieldMoveToUp) {
      setState(() {
        videoRepo.homeCon.value.textFieldMoveToUp = newValue;
      });
    }
  }

  @override
  void initState() {
    print("Dashboard inits");
    videoRepo.isOnHomePage.value = true;
    videoRepo.isOnHomePage.notifyListeners();
    _con = videoRepo.homeCon.value;
    _con.scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "_dashboardPage");
    musicAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 10),
    );
    musicAnimationController.repeat();
    // print(userRepo.currentUser.value);
    // print(userRepo.currentUser.value.email);
    if (userRepo.currentUser.value.email != null) {
      Timer(Duration(milliseconds: 300), () {
        _con.checkEulaAgreement();
      });
    }
    // _con.getAds();
    super.initState();
  }

  waitForSometime() {
    print("waitForSometime");
    Future.delayed(Duration(seconds: 2));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.toString() == "AppLifecycleState.paused" ||
        state.toString() == "AppLifecycleState.inactive" ||
        state.toString() == "AppLifecycleState.detached" ||
        state.toString() == "AppLifecycleState.suspending ") {
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
      } else {
        videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
      }
      print("Print minimized");
    } else {
      print("Print maximized");
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        _con.playController(videoRepo.homeCon.value.swiperIndex);
      } else {
        _con.playController2(videoRepo.homeCon.value.swiperIndex);
      }
    }
  }

  @override
  dispose() async {
    if (!videoRepo.homeCon.value.showFollowingPage.value) {
      videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
    } else {
      videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
    }
    if (!videoRepo.firstLoad.value) {
      print("not first load");
      int count = 0;
      if (videoRepo.homeCon.value.videoControllers.length > 0) {
        videoRepo.homeCon.value.videoControllers.forEach((key, value) async {
          await value.dispose();
          videoRepo.homeCon.value.videoControllers.remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.value.initializeVideoPlayerFutures.remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.notifyListeners();
          count++;
        });
      }
      int count1 = 0;
      if (videoRepo.homeCon.value.videoControllers2.length > 0) {
        videoRepo.homeCon.value.videoControllers2.forEach((key, value) async {
          await value.dispose();
          videoRepo.homeCon.value.videoControllers2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count1));
          videoRepo.homeCon.value.initializeVideoPlayerFutures2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count1));
          count1++;
        });
      }
    } else {
      print("first load");
      videoRepo.firstLoad.value = false;
      videoRepo.firstLoad.notifyListeners();
      videoRepo.homeCon.value.playController(0);
    }
    musicAnimationController.dispose(); // you need this
    super.dispose();
  }

  validateForm(Video videoObj, context) {
    if (videoRepo.homeCon.value.formKey.currentState.validate()) {
      videoRepo.homeCon.value.formKey.currentState.save();
      videoRepo.homeCon.value.submitReport(videoObj, context);
    }
  }

  reportLayout(context, Video videoObj) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: videoRepo.homeCon.value.showReportMsg,
            builder: (context, showMsg, _) {
              return AlertDialog(
                title: showMsg
                    ? Text("REPORT SUBMITTED!",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ))
                    : Text("REPORT",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )),
                insetPadding: EdgeInsets.zero,
                content: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: videoRepo.homeCon.value.formKey,
                  child: !showMsg
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Color(0xffffffff),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    hint: new Text("Select Type", textAlign: TextAlign.center),
                                    iconEnabledColor: Colors.black,
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                    ),
                                    value: videoRepo.homeCon.value.selectedType,
                                    onChanged: (newValue) {
                                      setState(() {
                                        videoRepo.homeCon.value.selectedType = newValue;
                                      });
                                    },
                                    validator: (value) => value == null ? 'This field is required!' : null,
                                    items: videoRepo.homeCon.value.reportType.map((String val) {
                                      return new DropdownMenuItem(
                                        value: val,
                                        child: new Text(
                                          val,
                                          style: new TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Description',
                              ),
                              onChanged: (String val) {
                                setState(() {
                                  _con.description = val;
                                });
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                                      setState(() {
                                        if (!videoRepo.homeCon.value.showReportLoader.value) {
                                          validateForm(videoObj, context);
                                        }
                                      });
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 60,
                                    decoration: BoxDecoration(gradient: Gradients.blush),
                                    child: ValueListenableBuilder(
                                        valueListenable: videoRepo.homeCon.value.showReportLoader,
                                        builder: (context, reportLoader, _) {
                                          return Center(
                                            child: (!reportLoader)
                                                ? Text(
                                                    "Submit",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      fontFamily: 'RockWellStd',
                                                    ),
                                                  )
                                                : Helper.showLoaderSpinner(Colors.white),
                                          );
                                        }),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                      _con.videoController(videoRepo.homeCon.value.swiperIndex).play();
                                    } else {
                                      _con.videoController2(videoRepo.homeCon.value.swiperIndex2).play();
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 60,
                                    decoration: BoxDecoration(gradient: Gradients.blush),
                                    child: Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: Center(
                                child: Text(
                                  "Thanks for reporting. If we find this content to be in violation of our Guidelines, we will remove it.",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              );
            });
      },
    );
  }

  Widget build(BuildContext context) {
    print("BottomPAD");
    final viewInsets = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets, WidgetsBinding.instance.window.devicePixelRatio);
    if (viewInsets.bottom == 0.0) {
      if (_con.bannerShowOn.indexOf("1") > -1) {
        _con.paddingBottom = Platform.isAndroid ? 50.0 : 80.0;
      } else {
        _con.paddingBottom = 0;
      }
    } else {
      _con.paddingBottom = 0;
    }
    return Material(
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Colors.black,
        body: ValueListenableBuilder(
            valueListenable: _con.isVideoInitialized,
            builder: (context, bool isVideoInitialized, _) {
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () {
                      if (!videoRepo.homeCon.value.showFollowingPage.value) {
                        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                      } else {
                        videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                      }
                      Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                      _con.getVideos();
                      return;
                    },
                    child: Container(
                      // height: 100,
                      padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          homeWidget(),
                          ValueListenableBuilder(
                            valueListenable: videoRepo.homeCon.value.hideBottomBar,
                            builder: (context, bool hideBottomBarInView, _) {
                              print("hideBottomBarInView");
                              print(hideBottomBarInView);
                              return !hideBottomBarInView
                                  ? Positioned(
                                      bottom: MediaQuery.of(context).padding.bottom,
                                      width: MediaQuery.of(context).size.width,
                                      child: bottomToolbarWidget(
                                        videoRepo.homeCon.value.index,
                                        videoRepo.homeCon.value.pc3,
                                        videoRepo.homeCon.value.pc2,
                                      ),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  !isVideoInitialized
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        )
                      : Container(),
                  Positioned(
                    bottom: Platform.isAndroid ? 0 : 15,
                    child: ValueListenableBuilder(
                      valueListenable: videoRepo.homeCon.value.showBannerAd,
                      builder: (context, adLoader, _) {
                        return adLoader
                            ? Center(child: Container(width: MediaQuery.of(context).size.width, child: BannerAdWidget(AdSize.banner)))
                            : Container();
                      },
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget bottomToolbarWidget(index, PanelController pc3, PanelController pc2) {
    {
      return SizedBox(
        // height: 100,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black12.withOpacity(0.1), Colors.transparent],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ValueListenableBuilder(
                          valueListenable: videoRepo.homeCon.value.showHomeLoader,
                          builder: (context, homeLoader, _) {
                            return IconButton(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.all(0),
                              icon: homeLoader
                                  ? Image.asset(
                                      'assets/icons/reloading.gif',
                                      width: 30.0,
                                    )
                                  : SvgPicture.asset(
                                      "assets/icons/home.svg",
                                      width: 30,
                                      color: settingRepo.setting.value.dashboardIconColor,
                                    ),
                              onPressed: () async {
                                // await _con.bannerAd.dispose();
                                // _con.bannerAd = null;
                                if (!homeLoader) {
                                  if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                  } else {
                                    videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                  }
                                  videoRepo.homeCon.value.userVideoObj.value['userId'] = 0;
                                  videoRepo.homeCon.value.userVideoObj.value['videoId'] = 0;
                                  videoRepo.homeCon.value.userVideoObj.value['name'] = "";
                                  videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                  videoRepo.homeCon.value.showHomeLoader.value = true;
                                  videoRepo.homeCon.value.showHomeLoader.notifyListeners();
                                  await Future.delayed(
                                    Duration(seconds: 2),
                                  );

                                  Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                  _con.getVideos();
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.all(0),
                          icon: SvgPicture.asset(
                            "assets/icons/hash-tag.svg",
                            width: 30,
                            color: settingRepo.setting.value.dashboardIconColor,
                          ),
                          onPressed: () async {
                            // await _con.bannerAd.dispose();
                            // _con.bannerAd = null;
                            videoRepo.isOnHomePage.value = false;
                            videoRepo.isOnHomePage.notifyListeners();
                            if (!videoRepo.homeCon.value.showFollowingPage.value) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                            } else {
                              videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                            }

                            Navigator.pushReplacementNamed(
                              context,
                              '/hash-videos',
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      child: IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          "assets/icons/create-video.svg",
                          width: 60,
                          color: settingRepo.setting.value.dashboardIconColor,
                        ),
                        onPressed: () async {
                          // await _con.bannerAd.dispose();
                          // _con.bannerAd = null;
                          videoRepo.isOnHomePage.value = false;
                          videoRepo.isOnHomePage.notifyListeners();
                          setState(() {
                            videoRepo.homeCon.value.paddingBottom = 0.0;
                          });
                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                          } else {
                            videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                          }
                          if (currentUser.value.token != null) {
                            Navigator.pushReplacementNamed(context, '/video-recorder');
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPageView(userId: 0),
                              ),
                            );
                          }
                        },
                      ) /*IconButton(
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          "assets/icons/create-video.svg",
                          width: 30,
                          color: settingRepo.setting.value.dashboardIconColor,
                        )
                        */ /* Image.asset(
                          'assets/icons/video.png',
                          height: 100,
                          width: 100,
                        )*/ /*
                        ,
                        onPressed: () async {
                          // await _con.bannerAd.dispose();
                          // _con.bannerAd = null;
                          setState(() {
                            videoRepo.homeCon.value.bannerAd?.dispose();
                            videoRepo.homeCon.value.bannerAd = null;
                            videoRepo.homeCon.value.paddingBottom = 0.0;
                          });
                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                          } else {
                            videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                          }
                          if (currentUser.value.token != null) {
                            Navigator.pushReplacementNamed(context, '/video-recorder');
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPageView(userId: 0),
                              ),
                            );
                          }
                        },
                      )*/
                      ,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.all(0),
                          icon: SvgPicture.asset(
                            'assets/icons/chat.svg',
                            width: 30.0,
                            color: settingRepo.setting.value.dashboardIconColor,
                          ),
                          onPressed: () async {
                            videoRepo.isOnHomePage.value = false;
                            videoRepo.isOnHomePage.notifyListeners();
                            // await _con.bannerAd.dispose();
                            // _con.bannerAd = null;
                            if (!_con.showFollowingPage.value) {
                              _con.videoController(_con.swiperIndex)?.pause();
                            } else {
                              _con.videoController2(_con.swiperIndex2)?.pause();
                            }

                            setState(() {
                              _con.paddingBottom = 0.0;
                            });

                            if (currentUser.value.token != null) {
                              Navigator.pushReplacementNamed(
                                context,
                                "/user-chats",
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  // builder: (context) => LoginPageView(userId: 0),
                                  builder: (context) => LoginPageView(userId: 0),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.all(0),
                          icon: SvgPicture.asset(
                            "assets/icons/user.svg",
                            width: 30,
                            color: settingRepo.setting.value.dashboardIconColor,
                          ),
                          onPressed: () async {
                            // await _con.bannerAd.dispose();
                            // _con.bannerAd = null;
                            videoRepo.isOnHomePage.value = false;
                            videoRepo.isOnHomePage.notifyListeners();
                            if (!_con.showFollowingPage.value) {
                              _con.videoController(_con.swiperIndex)?.pause();
                            } else {
                              _con.videoController2(_con.swiperIndex2)?.pause();
                            }
                            setState(() {
                              videoRepo.homeCon.value.paddingBottom = 0.0;
                            });
                            if (!videoRepo.homeCon.value.showFollowingPage.value) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                            } else {
                              videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                            }
                            if (currentUser.value.token != null) {
                              Navigator.pushReplacementNamed(
                                context,
                                "/my-profile",
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPageView(userId: 0),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget homeWidget() {
    {
      videoRepo.dataLoaded.addListener(() async {
        if (videoRepo.dataLoaded.value) {
          // if (mounted) setState(() {});
          // _con.refresh();
          // if (mounted) _con.setState(() {});
        }
      });

      videoRepo.homeCon.value.loadMoreUpdateView.addListener(() {
        if (videoRepo.homeCon.value.loadMoreUpdateView.value) {
          if (mounted) setState(() {});
        }
      });

      Video videoObj;
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        videoObj = (videosData.value.videos.length > 0) ? videosData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex) : null;
      } else {
        videoObj = (followingUsersVideoData.value.videos.length > 0)
            ? followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex)
            : videoObj;

        if (videoObj == null) {
          videoObj = (videosData.value.videos.length > 0) ? videosData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex) : null;
        }
      }
      final commentField = TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
        obscureText: false,
        focusNode: videoRepo.homeCon.value.inputNode,
        keyboardType: TextInputType.text,
        controller: videoRepo.homeCon.value.commentController,
        onSaved: (String val) {
          videoRepo.homeCon.value.commentValue = val;
        },
        onChanged: (String val) {
          videoRepo.homeCon.value.commentValue = val;
        },
        onTap: () {
          setState(() {
            if (_con.bannerShowOn.indexOf("1") > -1) {
              _con.paddingBottom = 0;
            }
            videoRepo.homeCon.value.textFieldMoveToUp = true;
            videoRepo.homeCon.value.loadMoreUpdateView.value = true;
            videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
            Timer(
                Duration(milliseconds: 200),
                () => setState(() {
                      hgt = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets, WidgetsBinding.instance.window.devicePixelRatio)
                          .bottom;
                    }));
          });
        },
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(left: 10, top: 0),
          errorStyle: TextStyle(
            color: Color(0xFF210ed5),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            wordSpacing: 2.0,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "Say something nice...",
          hintStyle: TextStyle(color: Colors.white, fontSize: 14),
        ),
      );

      return (videoObj != null)
          ? SlidingUpPanel(
              controller: videoRepo.homeCon.value.pc,
              minHeight: 0,
              backdropEnabled: true,
              color: Colors.black,
              backdropColor: Colors.white,
              padding: EdgeInsets.only(top: 20, bottom: 0),
              header: Column(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 20,
                      child: Text(
                        "Comments (" + Helper.formatter(videoObj.totalComments.toString()) + ")",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: 0.2,
                    color: Colors.white,
                  )
                ],
              ),
              onPanelOpened: () async {
                if (_con.bannerShowOn.indexOf("1") > -1) {
                  setState(() {
                    _con.paddingBottom = 0;
                  });
                }
              },
              onPanelClosed: () {
                videoRepo.homeCon.value.showBannerAd.value = false;
                videoRepo.homeCon.value.showBannerAd.notifyListeners();
                setState(() {
                  if (_con.bannerShowOn.indexOf("1") > -1) {
                    _con.paddingBottom = Platform.isAndroid ? 50.0 : 80.0;
                  }
                });
                videoRepo.homeCon.value.textFieldMoveToUp = false;
                FocusScope.of(context).unfocus();
                // setState(() {
                videoRepo.homeCon.value.hideBottomBar.value = false;
                videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                videoRepo.homeCon.value.comments = [];
                // });
                videoRepo.homeCon.notifyListeners();
                videoRepo.homeCon.value.commentController = new TextEditingController(text: "");
                videoRepo.homeCon.value.loadMoreUpdateView.value = false;
                videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
              },
              borderRadius: BorderRadius.only(topRight: Radius.circular(50), topLeft: Radius.circular(50)),
              panel: Stack(
                fit: StackFit.loose,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  Positioned(
                    top: 40,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(50), topLeft: Radius.circular(50)),
                      ),
                      child: (videoRepo.homeCon.value.comments.length > 0)
                          ? Padding(
                              padding: videoRepo.homeCon.value.comments.length > 5
                                  ? currentUser.value.token != null
                                      ? EdgeInsets.only(bottom: 85)
                                      : EdgeInsets.zero
                                  : EdgeInsets.zero,
                              child: ListView.separated(
                                controller: videoRepo.homeCon.value.scrollController,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                itemCount: videoRepo.homeCon.value.comments.length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        dense: true,
                                        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                                        leading: InkWell(
                                          onTap: () {
                                            videoRepo.isOnHomePage.value = false;
                                            videoRepo.isOnHomePage.notifyListeners();
                                            videoRepo.homeCon.value.hideBottomBar.value = false;
                                            videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                                            videoRepo.homeCon.notifyListeners();
                                            if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                            } else {
                                              videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                            }
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    videoRepo.homeCon.value.comments.elementAt(i).userId == userRepo.currentUser.value.userId
                                                        ? MyProfileView()
                                                        : UsersProfileView(
                                                            userId: videoRepo.homeCon.value.comments.elementAt(i).userId,
                                                          ),
                                              ),
                                            );
                                            /*Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => UsersProfileView(userId: videoRepo.homeCon.value.comments.elementAt(i).userId),
                                              ),
                                            );*/
                                          },
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                fit: BoxFit.cover,
                                                image: videoRepo.homeCon.value.comments.elementAt(i).userDp.isNotEmpty
                                                    ? CachedNetworkImageProvider(
                                                        videoRepo.homeCon.value.comments.elementAt(i).userDp,
                                                      )
                                                    : AssetImage(
                                                        "assets/images/video-logo.png",
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: InkWell(
                                          onTap: () {
                                            videoRepo.isOnHomePage.value = false;
                                            videoRepo.isOnHomePage.notifyListeners();
                                            videoRepo.isOnHomePage.value = false;
                                            videoRepo.isOnHomePage.notifyListeners();
                                            videoRepo.homeCon.value.hideBottomBar.value = false;
                                            videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                                            videoRepo.homeCon.notifyListeners();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    videoRepo.homeCon.value.comments.elementAt(i).userId == userRepo.currentUser.value.userId
                                                        ? MyProfileView()
                                                        : UsersProfileView(
                                                            userId: videoRepo.homeCon.value.comments.elementAt(i).userId,
                                                          ),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                videoRepo.homeCon.value.comments.elementAt(i).userName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              videoRepo.homeCon.value.comments.elementAt(i).isVerified == true
                                                  ? Icon(
                                                      Icons.verified,
                                                      color: Colors.blueAccent,
                                                      size: 16,
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          child: Text(
                                            videoRepo.homeCon.value.comments.elementAt(i).comment,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                        trailing: userRepo.currentUser.value.userId == videoRepo.homeCon.value.comments.elementAt(i).userId ||
                                                userRepo.currentUser.value.userId == videoObj.userId
                                            ? Container(
                                                width: 50,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                      child: Text(
                                                        videoRepo.homeCon.value.comments.elementAt(i).time,
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 20,
                                                      width: 18,
                                                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                                      child: Center(
                                                        child: PopupMenuButton<int>(
                                                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                            color: settingRepo.setting.value.buttonColor,
                                                            icon: Icon(
                                                              Icons.more_vert,
                                                              size: 18,
                                                              color: settingRepo.setting.value.iconColor,
                                                            ),
                                                            onSelected: (int) {
                                                              if (int == 0) {
                                                                //edit
                                                                print("Edit Comment");
                                                                homeCon.value.onEditComment(i + 1, context);
                                                              } else {
                                                                //Delete
                                                                print("Delete Comment");
                                                                _con.showDeleteAlert(
                                                                    context,
                                                                    "Delete Confirmation",
                                                                    "Do you realy want to delete this comment",
                                                                    videoRepo.homeCon.value.comments.elementAt(i).commentId,
                                                                    videoObj.videoId);
                                                              }
                                                            },
                                                            itemBuilder: (context) {
                                                              return userRepo.currentUser.value.userId ==
                                                                      videoRepo.homeCon.value.comments.elementAt(i).userId
                                                                  ? [
                                                                      PopupMenuItem(
                                                                        height: 15,
                                                                        value: 0,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Text(
                                                                            "Edit",
                                                                            style: TextStyle(
                                                                              color: settingRepo.setting.value.buttonTextColor,
                                                                              // fontFamily: 'RockWellStd',
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      PopupMenuItem(
                                                                        height: 15,
                                                                        value: 1,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Text(
                                                                            "Delete",
                                                                            style: TextStyle(
                                                                              color: settingRepo.setting.value.buttonTextColor,
                                                                              // fontFamily: 'RockWellStd',
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ]
                                                                  : [
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
                                                                      )
                                                                    ];
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                child: Text(
                                                  videoRepo.homeCon.value.comments.elementAt(i).time,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color: Colors.white,
                                    thickness: 0.1,
                                  );
                                },
                              ),
                            )
                          : (videoObj.totalComments > 0)
                              ? SkeletonLoader(
                                  builder: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 18,
                                        ),
                                        SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  height: 8,
                                                  width: 80,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                width: double.infinity,
                                                height: 8,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                width: double.infinity,
                                                height: 8,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 15),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  width: 50,
                                                  height: 9,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  items: videoObj.totalComments > 4 ? 4 : videoObj.totalComments,
                                  period: Duration(seconds: 1),
                                  highlightColor: Colors.white60,
                                  direction: SkeletonDirection.ltr,
                                )
                              : Center(
                                  child: Text(
                                    "No comment available",
                                    style: TextStyle(color: Colors.grey, fontSize: 17, fontWeight: FontWeight.w500),
                                  ),
                                ),
                    ),
                  ),
                  currentUser.value.token != null
                      ? ValueListenableBuilder(
                          valueListenable: videoRepo.homeCon.value.editedComment,
                          builder: (context, int editCommentIndex, _) {
                            return Positioned(
                              bottom:
                                  /* (videoRepo.homeCon.value.textFieldMoveToUp)
                              ? hgt + 10
                              : */
                                  20,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                color: Color(0xff2e2f34),
                                child: Stack(
                                  alignment: Alignment.centerRight,
                                  //    child: commentField
                                  children: [
                                    commentField,
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          videoRepo.homeCon.value.textFieldMoveToUp = false;
                                        });
                                        if (videoRepo.homeCon.value.commentValue.trim() != '' && videoRepo.homeCon.value.commentValue != null) {
                                          print("editedComment");
                                          print(videoRepo.homeCon.value.editedComment.value);
                                          editCommentIndex > 0
                                              ? videoRepo.homeCon.value
                                                  .editComment(videoRepo.homeCon.value.editedComment.value - 1, videoObj.videoId, context)
                                              : videoRepo.homeCon.value.addComment(videoObj.videoId, context);
                                        }
                                        // FocusScope.of(context).unfocus();
                                        // FocusScope.of(context).requestFocus(FocusNode());
                                      },
                                      icon: Container(
                                        color: settingRepo.setting.value.buttonColor,
                                        height: 50,
                                        width: 50,
                                        child: Icon(
                                          Icons.send,
                                          color: settingRepo.setting.value.iconColor,
                                          size: 30.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                      : SizedBox(
                          height: 0,
                        ),
                  ValueListenableBuilder(
                      valueListenable: videoRepo.homeCon.value.commentsLoader,
                      builder: (context, loader, _) {
                        return loader
                            ? Center(
                                child: showLoaderSpinner(),
                              )
                            : SizedBox(
                                height: 0,
                              );
                      }),
                ],
              ),
              body: ValueListenableBuilder(
                  valueListenable: videoRepo.homeCon.value.showFollowingPage,
                  builder: (context, show, _) {
                    return !show
                        ? ValueListenableBuilder(
                            valueListenable: videosData,
                            builder: (context, VideoModel video, _) {
                              return Stack(
                                children: <Widget>[
                                  Swiper(
                                    controller: videoRepo.homeCon.value.swipeController,
                                    loop: false,
                                    index: videoRepo.homeCon.value.swiperIndex,
                                    control: new SwiperControl(
                                      color: Colors.transparent,
                                    ),
                                    onIndexChanged: (index) {
                                      if (videoRepo.homeCon.value.swiperIndex > index) {
                                        print("Prev Code");
                                        videoRepo.homeCon.value.previousVideo(index);
                                      } else {
                                        print("Next Code");
                                        videoRepo.homeCon.value.nextVideo(index);
                                      }
                                      videoRepo.homeCon.value.updateSwiperIndex(index);
                                      if (video.videos.length - index == 3) {
                                        videoRepo.homeCon.value
                                            .listenForMoreVideos()
                                            .whenComplete(() => unawaited(videoRepo.homeCon.value.preCacheVideos()));
                                      }
                                    },
                                    itemBuilder: (BuildContext context, int index) {
                                      print("AAAABCD");
                                      print(videoRepo.homeCon.value.initializeVideoPlayerFutures[video.videos.elementAt(index).url]);
                                      return GestureDetector(
                                          onTap: () {
                                            print("click Played");
                                            setState(() {
                                              _con.onTap = true;
                                              videoRepo.homeCon.notifyListeners();
                                              // If the video is playing, pause it.
                                              if (_con.videoController(_con.swiperIndex).value.isPlaying) {
                                                _con.videoController(_con.swiperIndex).pause();
                                                // setState(() {
                                                //   _con.lights = true;
                                                // });
                                              } else {
                                                // If the video is paused, play it.
                                                _con.videoController(_con.swiperIndex).play();
                                                // setState(() {
                                                //   _con.lights = false;
                                                // });
                                              }
                                            });
                                          },
                                          child: Stack(
                                            fit: StackFit.loose,
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                child: Center(
                                                  child: Container(
                                                    color: Colors.black,
                                                    // constraints: BoxConstraints(minWidth: 100, maxWidth: 500,maxHeight: 900,),
                                                    child: VideoPlayerWidget(
                                                        videoRepo.homeCon.value.videoController(index),
                                                        video.videos.elementAt(index),
                                                        videoRepo.homeCon.value.initializeVideoPlayerFutures[video.videos.elementAt(index).url]),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  // Top section
                                                  // Middle expanded
                                                  Container(
                                                    padding: new EdgeInsets.only(
                                                      bottom: videoRepo.homeCon.value.paddingBottom + MediaQuery.of(context).padding.bottom,
                                                    ),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: <Widget>[
                                                          VideoDescription(
                                                            video.videos.elementAt(index),
                                                            videoRepo.homeCon.value.pc3,
                                                          ),
                                                          sidebar(index, video)
                                                        ]),
                                                  ),
                                                  SizedBox(
                                                    height: 70.0,
                                                  ),
                                                ],
                                              ),
                                              (videoRepo.homeCon.value.swiperIndex == 0 && !videoRepo.homeCon.value.initializePage)
                                                  ? SafeArea(
                                                      child: Container(
                                                        height: MediaQuery.of(context).size.height / 4,
                                                        width: MediaQuery.of(context).size.width,
                                                        color: Colors.transparent,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ));
                                      // }
                                    },
                                    itemCount: video.videos.length,
                                    scrollDirection: Axis.vertical,
                                  ),
                                  ValueListenableBuilder(
                                      valueListenable: videoRepo.homeCon.value.userVideoObj,
                                      builder: (context, Map<String, dynamic> value, _) {
                                        return (value['userId'] == null || value['userId'] == 0) &&
                                                (value['videoId'] == null || value['videoId'] == 0)
                                            ? topSection(video)
                                            : Padding(
                                                padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.arrow_back_ios,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () async {
                                                            videoRepo.homeCon.value.userVideoObj.value['userId'] = 0;
                                                            videoRepo.homeCon.value.userVideoObj.value['videoId'] = 0;
                                                            videoRepo.homeCon.value.userVideoObj.value['name'] = '';
                                                            videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                                            if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                                            } else {
                                                              videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                                            }
                                                            // await videoRepo.homeCon.value.getFollowingUserVideos();
                                                            Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                                            _con.getVideos();
                                                          },
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Transform.translate(
                                                          offset: Offset(-10, 0),
                                                          child: Text(
                                                            value['name'] != "" && value['name'] != null
                                                                ? value['name'] + " Videos"
                                                                : value['userId'] != 0 && value['userId'] != null
                                                                    ? "My Videos"
                                                                    : "",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                      }),
                                ],
                              );
                            },
                          )
                        : ValueListenableBuilder(
                            valueListenable: followingUsersVideoData,
                            builder: (context, VideoModel video, _) {
                              print("videoRepo.homeCon.value.swiperIndex2");
                              print(videoRepo.homeCon.value.swiperIndex2);
                              return Stack(
                                children: <Widget>[
                                  (video.videos.length > 0)
                                      ? Swiper(
                                          controller: videoRepo.homeCon.value.swipeController2,
                                          loop: false,
                                          index: videoRepo.homeCon.value.swiperIndex2,
                                          control: new SwiperControl(
                                            color: Colors.transparent,
                                          ),
                                          onIndexChanged: (index) {
                                            if (videoRepo.homeCon.value.swiperIndex2 > index) {
                                              videoRepo.homeCon.value.previousVideo2(index);
                                            } else {
                                              videoRepo.homeCon.value.nextVideo2(index);
                                            }
                                            videoRepo.homeCon.value.updateSwiperIndex2(index);
                                            if (video.videos.length - index == 3) {
                                              videoRepo.homeCon.value.listenForMoreUserFollowingVideos();
                                            }
                                          },
                                          itemBuilder: (BuildContext context, int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                print("click Played");
                                                setState(() {
//                  print("Entered ");

                                                  // If the video is playing, pause it.
                                                  if (_con.videoController2(_con.swiperIndex2).value.isPlaying) {
                                                    _con.videoController2(_con.swiperIndex2).pause();
                                                    // setState(() {
                                                    //   _con.lights = true;
                                                    // });
                                                  } else {
                                                    // If the video is paused, play it.
                                                    _con.videoController2(_con.swiperIndex2).play();
                                                    // setState(() {
                                                    //   _con.lights = false;
                                                    // });
                                                  }
                                                });
                                              },
                                              child: new Stack(
                                                fit: StackFit.loose,
                                                children: <Widget>[
                                                  Center(
                                                    child: Container(
                                                      color: Colors.black,
                                                      constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                                                      child: VideoPlayerWidget(
                                                          videoRepo.homeCon.value.videoController2(index),
                                                          video.videos.elementAt(index),
                                                          videoRepo.homeCon.value.initializeVideoPlayerFutures2[video.videos.elementAt(index).url]),
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: <Widget>[
                                                          // Top section
                                                          // Middle expanded
                                                          Container(
                                                            padding: new EdgeInsets.only(
                                                                bottom:
                                                                    videoRepo.homeCon.value.paddingBottom + MediaQuery.of(context).padding.bottom),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: <Widget>[
                                                                  VideoDescription(
                                                                    video.videos.elementAt(index),
                                                                    videoRepo.homeCon.value.pc3,
                                                                  ),
                                                                  sidebar(index, video)
                                                                ]),
                                                          ),
                                                          SizedBox(
                                                            height: 70.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  (videoRepo.homeCon.value.swiperIndex2 == 0 && !videoRepo.homeCon.value.initializePage)
                                                      ? SafeArea(
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                  context,
                                                                ).size.height /
                                                                4,
                                                            width: MediaQuery.of(
                                                              context,
                                                            ).size.width,
                                                            color: Colors.transparent,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            );
                                            // }
                                          },
                                          itemCount: video.videos.length,
                                          scrollDirection: Axis.vertical,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(color: Colors.black87),
                                          height: MediaQuery.of(context).size.height,
                                          width: MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                  videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                                } else {
                                                  videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                                }
                                                if (currentUser.value.token != null) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/users',
                                                  );
                                                } else {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LoginPageView(userId: 0),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.all(10),
                                                      padding: EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(100),
                                                          border: Border.all(width: 2, color: Colors.white)),
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "This is your feed of user you follow.",
                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      "You can follow people or subscribe to hashtags.",
                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Icon(Icons.person_add, color: Colors.white, size: 45),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  topSection(video),
                                ],
                              );
                            },
                          );
                  }),
            )
          : Container(
              decoration: BoxDecoration(color: Colors.black87),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Following",
                            style: TextStyle(
                              color: settingRepo.setting.value.headingColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            height: 15,
                            width: 2,
                            color: settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            child: Text(
                              "Featured",
                              style: TextStyle(
                                color: settingRepo.setting.value.headingColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                              ),
                            ),
                            onTap: () async {
                              if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                              } else {
                                videoRepo.homeCon.value.showFollowingPage.value = false;
                                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                              }

                              Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                              _con.getVideos();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Center(
                      child: showLoaderSpinner(),
                    ),
                  ),
                ],
              ),
            );
    }
  }

  Widget topSection(video) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black45,
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.showFollowingPage,
                    builder: (context, show, _) {
                      return Text("Following",
                          style: TextStyle(
                            color: show ? settingRepo.setting.value.headingColor : settingRepo.setting.value.textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                          ));
                    }),
                onTap: () async {
                  videoRepo.homeCon.value.showFollowingPage.value = true;
                  videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                  if (!videoRepo.homeCon.value.showFollowingPage.value) {
                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                  } else {
                    videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                  }
                  Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                  videoRepo.homeCon.value.getFollowingUserVideos();
                },
              ),
              SizedBox(
                width: 8,
              ),
              Container(
                height: 15,
                width: 2,
                color: settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.showFollowingPage,
                    builder: (context, show, _) {
                      return Text(
                        "Featured",
                        style: TextStyle(
                          color: show ? settingRepo.setting.value.textColor : settingRepo.setting.value.headingColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
                        ),
                      );
                    }),
                onTap: () async {
                  if (!videoRepo.homeCon.value.showFollowingPage.value) {
                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                  } else {
                    videoRepo.homeCon.value.showFollowingPage.value = false;
                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                    videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                  }
                  Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                  _con.getVideos();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMusicPlayerAction(index, video) {
    Video videoObj = video.videos.elementAt(index);
    return GestureDetector(
      onTap: () async {
        if (currentUser.value.token != null) {
          if (!videoRepo.homeCon.value.showFollowingPage.value) {
            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
          } else {
            videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
          }
          // await videoRepo.homeCon.value.disposeVideos();
          videoRepo.homeCon.value.soundShowLoader.value = true;
          videoRepo.homeCon.value.soundShowLoader.notifyListeners();
          SoundData sound = await soundRepo.getSound(videoObj.soundId);
          soundRepo.selectSound(sound).whenComplete(() {
            videoRepo.homeCon.value.soundShowLoader.value = false;
            videoRepo.homeCon.value.soundShowLoader.notifyListeners();
            Navigator.pushReplacementNamed(
              context,
              "/video-recorder",
            );
          });
        } else {
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
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(musicAnimationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: 60,
          height: 60,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: musicGradient,
                  borderRadius: BorderRadius.circular(50 / 2),
                ),
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.soundShowLoader,
                    builder: (context, loader, _) {
                      return (!loader)
                          ? Container(
                              height: 45.0,
                              width: 45.0,
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(50),
                                image: new DecorationImage(
                                  image: new CachedNetworkImageProvider(
                                    videoObj.soundImageUrl,
                                    maxHeight: 100,
                                    maxWidth: 100,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Helper.showLoaderSpinner(Colors.white);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sidebar(index, video) {
    Video videoObj = video.videos.elementAt(index);

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    videoRepo.homeCon.value.encodedVideoId = stringToBase64.encode(videoRepo.homeCon.value.encKey + videoObj.videoId.toString());
    return Container(
      padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom - 30 > 0 ? videoRepo.homeCon.value.paddingBottom - 30 : 20),
      width: 70.0,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(
          //mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          //mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Divider(
              color: Colors.transparent,
              height: 10,
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 50.0,
              width: 50.0,
              child: IconButton(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(
                  top: 9,
                  bottom: 6,
                  left: 5.0,
                  right: 5.0,
                ),
                icon: (videoObj.isLike)
                    ? Image.asset(
                        'assets/icons/like.png',
                        width: 30.0,
                      )
                    : SvgPicture.asset(
                        'assets/icons/broken-heart.svg',
                        width: 30.0,
                        color: settingRepo.setting.value.dashboardIconColor,
                      ),
                onPressed: () {
                  if (currentUser.value.token != null) {
                    if (!videoRepo.homeCon.value.showFollowingPage.value) {
                      setState(() {
                        videoRepo.homeCon.value.likeVideo(index);
                      });
                    } else {
                      setState(() {
                        videoRepo.homeCon.value.likeFollowingVideo(index);
                      });
                    }
                  } else {
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
              ),
            ),
            Divider(
              color: Colors.transparent,
              height: 5.0,
            ),
            Text(
              Helper.formatter(videoObj.totalLikes.toString()),
              style: TextStyle(
                color: settingRepo.setting.value.textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 15.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                    icon: SvgPicture.asset(
                      'assets/icons/comments.svg',
                      width: 30.0,
                      color: settingRepo.setting.value.dashboardIconColor,
                    ),
                    onPressed: () {
                      if (_con.bannerShowOn.indexOf("1") > -1) {
                        setState(() {
                          _con.paddingBottom = 0;
                        });
                      }
                      videoRepo.homeCon.value.hideBottomBar.value = true;
                      videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                      videoRepo.homeCon.value.videoIndex = index;
                      videoRepo.homeCon.value.showBannerAd.value = false;
                      videoRepo.homeCon.value.showBannerAd.notifyListeners();
                      videoRepo.homeCon.value.pc.open();
                      videoRepo.homeCon.value.getComments(videoObj).whenComplete(() {
                        Timer(Duration(seconds: 1), () => setState(() {}));
                      });
                    },
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 5.0,
                ),
                Text(
                  Helper.formatter(videoObj.totalComments.toString()),
                  style: TextStyle(
                    color: settingRepo.setting.value.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 15.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                    icon: SvgPicture.asset(
                      'assets/icons/views.svg',
                      width: 40.0,
                      color: settingRepo.setting.value.dashboardIconColor,
                    ),
                    onPressed: () {},
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 5.0,
                ),
                Text(
                  Helper.formatter(videoObj.totalViews.toString()),
                  style: TextStyle(
                    color: settingRepo.setting.value.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 15.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 50.0,
              width: 50.0,
              child: ValueListenableBuilder(
                  valueListenable: videoRepo.homeCon.value.shareShowLoader,
                  builder: (context, shareLoader, _) {
                    return (!shareLoader)
                        ? IconButton(
                            alignment: Alignment.topCenter,
                            icon: SvgPicture.asset(
                              'assets/icons/share.svg',
                              width: 30.0,
                              color: settingRepo.setting.value.dashboardIconColor,
                            ),
                            onPressed: () async {
                              videoRepo.homeCon.value.shareShowLoader.value = true;
                              videoRepo.homeCon.value.shareShowLoader.notifyListeners();
                              Share.share('${GlobalConfiguration().get('share_text')}');
                              await Future.delayed(
                                Duration(seconds: 2),
                              );
                              videoRepo.homeCon.value.shareShowLoader.value = false;
                              videoRepo.homeCon.value.shareShowLoader.notifyListeners();
                            },
                          )
                        : showLoaderSpinner();
                  }),
            ),
            Divider(
              color: Colors.transparent,
              height: 5.0,
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 15.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 50.0,
              width: 50.0,
              child: IconButton(
                alignment: Alignment.topCenter,
                icon: Icon(
                  Icons.report_problem,
                  size: 30,
                  color: settingRepo.setting.value.dashboardIconColor,
                ),
                onPressed: () async {
                  if (currentUser.value.token != null) {
                    videoRepo.homeCon.value.showReportMsg.value = false;
                    videoRepo.homeCon.value.showReportMsg.notifyListeners();
                    reportLayout(context, videoObj);
                  } else {
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
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 15.0,
        ),
        (videoObj.soundId > 0)
            ? _getMusicPlayerAction(index, video)
            : SizedBox(
                height: 0,
              ),
        (videoObj.soundId > 0)
            ? Divider(
                color: Colors.transparent,
                height: 5.0,
              )
            : SizedBox(
                height: 0,
              ),
      ]),
    );
  }

  static showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Duration duration;
  Duration position;
  LinearGradient get musicGradient => LinearGradient(
      colors: [Colors.grey[800], Colors.grey[900], Colors.grey[900], Colors.grey[800]],
      stops: [0.0, 0.4, 0.6, 1.0],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight);
}
