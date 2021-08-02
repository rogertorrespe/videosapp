import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/hash_videos_controller.dart';
import '../helpers/app_config.dart';
import '../helpers/helper.dart';
import '../models/hash_videos_model.dart';
import '../models/search_model.dart';
import '../repositories/hash_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/user_profile_view.dart';
import '../widgets/AdsWidget.dart';
import 'hash_video_view.dart';
import 'my_profile_view.dart';

class HashVideosView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  HashVideosView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HashVideosViewState createState() => _HashVideosViewState();
}

class _HashVideosViewState extends StateMVC<HashVideosView> {
  HashVideosController _con;
  int page = 1;
  _HashVideosViewState() : super(HashVideosController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.getData(page);
    _con.getAds();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            videoRepo.homeCon.value.showFollowingPage.value = false;
            videoRepo.homeCon.value.showFollowingPage.notifyListeners();
            videoRepo.homeCon.value.getVideos();
            Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
            return Future.value(true);
          },
          child: _con.searchKeyword == ""
              ? ValueListenableBuilder(
                  valueListenable: hashData,
                  builder: (context, HashVideosModel data, _) {
                    return ModalProgressHUD(
                      inAsyncCall: _con.showLoader,
                      progressIndicator: Helper.showLoaderSpinner(Colors.white),
                      child: SafeArea(
                        child: Scaffold(
                          key: _con.scaffoldKey,
                          backgroundColor: settingRepo.setting.value.bgColor,
                          resizeToAvoidBottomInset: false,
                          body: SingleChildScrollView(
                            child: Container(
                              color: settingRepo.setting.value.bgColor,
                              // height: MediaQuery.of(context).size.height,
                              // width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 15, 0, 0),
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
                                              videoRepo.homeCon.value.getVideos();
                                              Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                            },
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              size: 20,
                                              color: settingRepo.setting.value.iconColor,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width - 50,
                                              child: TextField(
                                                controller: _con.searchController,
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.iconColor,
                                                  fontSize: 16.0,
                                                ),
                                                obscureText: false,
                                                keyboardType: TextInputType.text,
                                                onChanged: (String val) {
                                                  setState(() {
                                                    _con.searchKeyword = val;
                                                  });
                                                  // if (val.length > 2) {
                                                  Timer(Duration(seconds: 1), () {
                                                    _con.getSearchData(1);
                                                  });
                                                  // }
                                                },
                                                decoration: new InputDecoration(
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                                  ),
                                                  hintText: "Search",
                                                  hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                                                  //contentPadding:EdgeInsets.all(10),
                                                  suffixIcon: IconButton(
                                                    padding: EdgeInsets.only(bottom: 12),
                                                    onPressed: () {
                                                      _con.searchController.clear();
                                                      setState(() {
                                                        _con.searchKeyword = "";
                                                      });
                                                      _con.getData(1);
                                                    },
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: (_con.searchKeyword.length > 0) ? Colors.grey : settingRepo.setting.value.bgColor,
                                                      size: 16,
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
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10, left: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            child: Text(
                                              'Challenges',
                                              style: TextStyle(
                                                color: settingRepo.setting.value.headingColor,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      (data.banners != null)
                                          ? Container(
                                              height: 150,
                                              width: MediaQuery.of(context).size.width,
                                              child: CarouselSlider(
                                                options: CarouselOptions(
                                                  enlargeCenterPage: true,
                                                  viewportFraction: 0.8,
                                                  aspectRatio: 2.0,
                                                  height: 150.0,
                                                  initialPage: 0,
                                                  autoPlay: true,
                                                  autoPlayInterval: Duration(seconds: 8),
                                                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                                                  enableInfiniteScroll: true,
                                                  reverse: false,
                                                ),
                                                items: data.banners.map((var value) {
                                                  return Builder(
                                                    builder: (BuildContext context) {
                                                      return /*AnimationConfiguration.staggeredList(
                                                    position: 0,
                                                    duration: const Duration(milliseconds: 250),
                                                    child: SlideAnimation(
                                                      verticalOffset: 20.0,
                                                      child: FadeInAnimation(*/
                                                          Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        child: CachedNetworkImage(
                                                          imageUrl: value.banner,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context, url) => Center(
                                                            child: Helper.showLoaderSpinner(Colors.white),
                                                          ),
                                                        ),
                                                      );
                                                      //     ),
                                                      //   ),
                                                      // );
                                                    },
                                                  );
                                                }).toList(),
                                              ))
                                          : Container(),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 13, bottom: 2, left: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            child: Text(
                                              'Recommended',
                                              style: TextStyle(
                                                color: settingRepo.setting.value.headingColor,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      (data.videos != null && data.videos.length > 0)
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: MediaQuery.of(context).size.height - 310,
                                                child: GridView.builder(
                                                  controller: _con.scrollController,
                                                  primary: false,
                                                  padding: const EdgeInsets.all(2),
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: (itemWidth / itemHeight),
                                                    crossAxisSpacing: 15,
                                                    mainAxisSpacing: 15,
                                                    crossAxisCount: 3,
                                                  ),
                                                  itemCount: data.videos.length,
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
                                                        print("Click Hash Videos");
                                                        print(data.videos[i].userName);

                                                        videoRepo.homeCon.value.userVideoObj.value['userId'] = data.videos[i].userId;
                                                        videoRepo.homeCon.value.userVideoObj.value['videoId'] = data.videos[i].id;
                                                        videoRepo.homeCon.value.userVideoObj.value['name'] = data.videos[i].userName + "'s";

                                                        videoRepo.homeCon.value.getVideos().whenComplete(() {
                                                          videoRepo.homeCon.notifyListeners();
                                                          Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                                        });
                                                      },
                                                      child: Stack(
                                                        alignment: Alignment.center,
                                                        children: <Widget>[
                                                          Container(
                                                              height: MediaQuery.of(context).size.height,
                                                              width: MediaQuery.of(context).size.width,
                                                              child: data.videos[i].thumb != ""
                                                                  ? Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(settingRepo.setting.value.gridBorderRadius),
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
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(
                                                                          5.0,
                                                                        ),
                                                                        child: CachedNetworkImage(
                                                                          imageUrl: data.videos[i].thumb,
                                                                          placeholder: (context, url) => Center(
                                                                            child: Helper.showLoaderSpinner(Colors.white),
                                                                          ),
                                                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : ClipRRect(
                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                      child: Image.asset(
                                                                        'assets/images/noVideo.jpg',
                                                                        fit: BoxFit.fill,
                                                                      ),
                                                                    )),
                                                          Positioned(
                                                            bottom: 20,
                                                            child: Container(
                                                              width: 35.0,
                                                              height: 35.0,
                                                              decoration: new BoxDecoration(
                                                                borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                                border: new Border.all(
                                                                  color: settingRepo.setting.value.dpBorderColor,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Container(
                                                                width: 35.0,
                                                                height: 35.0,
                                                                decoration: new BoxDecoration(
                                                                  image: new DecorationImage(
                                                                      image: (data.videos[i].dp != "")
                                                                          ? CachedNetworkImageProvider(
                                                                              data.videos[i].dp,
                                                                            )
                                                                          : AssetImage(
                                                                              'assets/images/default-user.png',
                                                                            ),
                                                                      fit: BoxFit.contain),
                                                                  borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 5,
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  data.videos[i].userName,
                                                                  style: TextStyle(
                                                                    color: settingRepo.setting.value.textColor,
                                                                    fontSize: 11,
                                                                    fontFamily: 'RockWellStd',
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                data.videos[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                                data.videos[i].isVerified == true
                                                                    ? Icon(
                                                                        Icons.verified,
                                                                        color: Colors.blueAccent,
                                                                        size: 16,
                                                                      )
                                                                    : Container(),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    /*),
                                                  ),
                                                );*/
                                                  },
                                                ),
                                              ),
                                            )
                                          : (!_con.showLoader)
                                              ? Center(
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.height - 360,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.videocam,
                                                          size: 30,
                                                          color: settingRepo.setting.value.iconColor,
                                                        ),
                                                        Text(
                                                          "No Videos Found",
                                                          style: TextStyle(
                                                            color: settingRepo.setting.value.textColor,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
              : ValueListenableBuilder(
                  valueListenable: searchData,
                  builder: (context, SearchModel data, _) {
                    print("search data");
                    print(data.users);
                    print(data.hashTags);
                    print(data.videos);
                    return ModalProgressHUD(
                      inAsyncCall: _con.showLoader,
                      progressIndicator: Helper.showLoaderSpinner(Colors.white),
                      child: SafeArea(
                        child: Scaffold(
                          key: _con.scaffoldKey,
                          backgroundColor: settingRepo.setting.value.bgColor,
                          resizeToAvoidBottomInset: false,
                          body: SingleChildScrollView(
                            child: Container(
                              color: settingRepo.setting.value.bgColor,
                              // height: MediaQuery.of(context).size.height,
                              // width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 15, 0, 0),
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
                                              videoRepo.homeCon.value.getVideos();
                                              Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                            },
                                            child: Icon(
                                              Icons.arrow_back_ios,
                                              size: 20,
                                              color: settingRepo.setting.value.iconColor,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width - 50,
                                              child: TextField(
                                                controller: _con.searchController,
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.iconColor,
                                                  fontSize: 16.0,
                                                ),
                                                obscureText: false,
                                                keyboardType: TextInputType.text,
                                                onChanged: (String val) {
                                                  setState(() {
                                                    _con.searchKeyword = val;
                                                  });
                                                  if (val.length > 2) {
                                                    Timer(Duration(seconds: 1), () {
                                                      _con.getSearchData(1);
                                                    });
                                                  }
                                                  if (val.length == 0) {
                                                    _con.getData(1);
                                                  }
                                                },
                                                decoration: new InputDecoration(
                                                  border: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                                  ),
                                                  hintText: "Search",
                                                  hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                                                  //contentPadding:EdgeInsets.all(10),
                                                  suffixIcon: IconButton(
                                                    padding: EdgeInsets.only(bottom: 12),
                                                    onPressed: () {
                                                      _con.searchController.clear();
                                                      setState(() {
                                                        _con.searchKeyword = "";
                                                      });
                                                      _con.getData(1);
                                                    },
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: (_con.searchKeyword.length > 0) ? Colors.grey : settingRepo.setting.value.bgColor,
                                                      size: 16,
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
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10, left: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            child: Text(
                                              'Tags',
                                              style: TextStyle(
                                                color: settingRepo.setting.value.headingColor,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      (data.hashTags != null && data.hashTags.length > 0)
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: App(context).appHeight(12),
                                                child: ListView.builder(
                                                  controller: _con.hashScrollController,
                                                  primary: false,
                                                  scrollDirection: Axis.horizontal,
                                                  padding: const EdgeInsets.all(10),
                                                  itemCount: data.hashTags.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    return Container(
                                                      padding: EdgeInsets.all(3.0),
                                                      child: InkWell(
                                                        onTap: () async {
                                                          print("Click Hashtag");
                                                          print(data.hashTags[i].toString());
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => HashVideoView(
                                                                hashTag: data.hashTags[i].toString(),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Container(
                                                            decoration: BoxDecoration(
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
                                                              color: settingRepo.setting.value.buttonColor,
                                                            ),
                                                            padding: const EdgeInsets.all(10),
                                                            child: Text(
                                                              "#" + data.hashTags[i].toString(),
                                                              style: TextStyle(color: settingRepo.setting.value.buttonTextColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    /*),
                                                  ),
                                                );*/
                                                  },
                                                ),
                                              ),
                                            )
                                          : (!_con.showLoader)
                                              ? Center(
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.height / 4,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.person,
                                                          size: 30,
                                                          color: settingRepo.setting.value.iconColor,
                                                        ),
                                                        Text(
                                                          "No Tags Found",
                                                          style: TextStyle(
                                                            color: settingRepo.setting.value.textColor,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10, left: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            child: Text(
                                              'Users',
                                              style: TextStyle(
                                                color: settingRepo.setting.value.headingColor,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      (data.users != null && data.users.length > 0)
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: App(context).appHeight(25),
                                                child: ListView.builder(
                                                  controller: _con.userScrollController,
                                                  primary: false,
                                                  scrollDirection: Axis.horizontal,
                                                  padding: const EdgeInsets.all(2),

                                                  /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: (itemWidth / itemHeight),
                                                    crossAxisSpacing: 15,
                                                    mainAxisSpacing: 15,
                                                    crossAxisCount: 1,
                                                  ),*/
                                                  itemCount: data.users.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    return Container(
                                                      padding: EdgeInsets.all(3.0),
                                                      width: App(context).appWidth(30),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          print("Click User Video");
                                                          print(data.users[i].username);
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => data.users[i].userId == userRepo.currentUser.value.userId
                                                                  ? MyProfileView()
                                                                  : UsersProfileView(
                                                                      userId: data.users[i].userId,
                                                                    ),
                                                            ),
                                                          );
                                                        },
                                                        child: Stack(
                                                          alignment: Alignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              height: MediaQuery.of(context).size.height,
                                                              width: MediaQuery.of(context).size.width,
                                                              child: data.users[i].userDP != ""
                                                                  ? Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(settingRepo.setting.value.gridBorderRadius),
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
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(
                                                                          5.0,
                                                                        ),
                                                                        child: CachedNetworkImage(
                                                                          imageUrl: data.users[i].userDP,
                                                                          placeholder: (context, url) => Center(
                                                                            child: Helper.showLoaderSpinner(Colors.white),
                                                                          ),
                                                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : ClipRRect(
                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                      child: Image.asset(
                                                                        'assets/images/noVideo.jpg',
                                                                        fit: BoxFit.fill,
                                                                      ),
                                                                    ),
                                                            ),
                                                            Positioned(
                                                              bottom: 20,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                                                    child: Text(
                                                                      "${data.users[i].fName}  \n"
                                                                      "${data.users[i].lName} ",
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        color: settingRepo.setting.value.textColor,
                                                                        fontSize: 11,
                                                                        fontFamily: 'RockWellStd',
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  data.users[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                                  data.users[i].isVerified == true
                                                                      ? Icon(
                                                                          Icons.verified,
                                                                          color: Colors.blueAccent,
                                                                          size: 16,
                                                                        )
                                                                      : Container(),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 5,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                                                    child: Text(
                                                                      data.users[i].username,
                                                                      style: TextStyle(
                                                                        color: settingRepo.setting.value.textColor,
                                                                        fontSize: 11,
                                                                        fontFamily: 'RockWellStd',
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  data.users[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                                  data.users[i].isVerified == true
                                                                      ? Icon(
                                                                          Icons.verified,
                                                                          color: Colors.blueAccent,
                                                                          size: 16,
                                                                        )
                                                                      : Container(),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                    /*),
                                                  ),
                                                );*/
                                                  },
                                                ),
                                              ),
                                            )
                                          : (!_con.showLoader)
                                              ? Center(
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.height / 4,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.person,
                                                          size: 30,
                                                          color: settingRepo.setting.value.iconColor,
                                                        ),
                                                        Text(
                                                          "No Users Found",
                                                          style: TextStyle(
                                                            color: settingRepo.setting.value.textColor,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 13, bottom: 2, left: 10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            child: Text(
                                              'Videos',
                                              style: TextStyle(
                                                color: settingRepo.setting.value.headingColor,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      (data.videos != null && data.videos.length > 0)
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: App(context).appHeight(35),
                                                child: ListView.builder(
                                                  controller: _con.videoScrollController,
                                                  primary: false,
                                                  scrollDirection: Axis.horizontal,
                                                  padding: const EdgeInsets.all(2),

                                                  /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: (itemWidth / itemHeight),
                                                    crossAxisSpacing: 15,
                                                    mainAxisSpacing: 15,
                                                    crossAxisCount: 1,
                                                  ),*/
                                                  itemCount: data.videos.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    return Container(
                                                      padding: EdgeInsets.all(3.0),
                                                      width: App(context).appWidth(43),
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          print("Click Hash Videos");
                                                          print(data.videos[i].userName);

                                                          videoRepo.homeCon.value.userVideoObj.value['userId'] = data.videos[i].userId;
                                                          videoRepo.homeCon.value.userVideoObj.value['videoId'] = data.videos[i].id;
                                                          videoRepo.homeCon.value.userVideoObj.value['name'] = data.videos[i].userName + "'s";

                                                          videoRepo.homeCon.value.getVideos().whenComplete(() {
                                                            videoRepo.homeCon.notifyListeners();
                                                            Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                                          });
                                                        },
                                                        child: Stack(
                                                          alignment: Alignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                                height: MediaQuery.of(context).size.height,
                                                                width: MediaQuery.of(context).size.width,
                                                                child: data.videos[i].thumb != ""
                                                                    ? Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(settingRepo.setting.value.gridBorderRadius),
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
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                            5.0,
                                                                          ),
                                                                          child: CachedNetworkImage(
                                                                            imageUrl: data.videos[i].thumb,
                                                                            placeholder: (context, url) => Center(
                                                                              child: Helper.showLoaderSpinner(Colors.white),
                                                                            ),
                                                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : ClipRRect(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        child: Image.asset(
                                                                          'assets/images/noVideo.jpg',
                                                                          fit: BoxFit.fill,
                                                                        ),
                                                                      )),
                                                            Positioned(
                                                              bottom: 20,
                                                              child: Container(
                                                                width: 35.0,
                                                                height: 35.0,
                                                                decoration: new BoxDecoration(
                                                                  borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                                  border: new Border.all(
                                                                    color: settingRepo.setting.value.dpBorderColor,
                                                                    width: 1.0,
                                                                  ),
                                                                ),
                                                                child: Container(
                                                                  width: 35.0,
                                                                  height: 35.0,
                                                                  decoration: new BoxDecoration(
                                                                    image: new DecorationImage(
                                                                        image: (data.videos[i].dp != "")
                                                                            ? CachedNetworkImageProvider(
                                                                                data.videos[i].dp,
                                                                              )
                                                                            : AssetImage(
                                                                                'assets/images/default-user.png',
                                                                              ),
                                                                        fit: BoxFit.contain),
                                                                    borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 5,
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    data.videos[i].userName,
                                                                    style: TextStyle(
                                                                      color: settingRepo.setting.value.textColor,
                                                                      fontSize: 11,
                                                                      fontFamily: 'RockWellStd',
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  data.videos[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                                  data.videos[i].isVerified == true
                                                                      ? Icon(
                                                                          Icons.verified,
                                                                          color: Colors.blueAccent,
                                                                          size: 16,
                                                                        )
                                                                      : Container(),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                    /*),
                                                  ),
                                                );*/
                                                  },
                                                ),
                                              ),
                                            )
                                          : (!_con.showLoader)
                                              ? Center(
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.height / 4,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.videocam,
                                                          size: 30,
                                                          color: settingRepo.setting.value.iconColor,
                                                        ),
                                                        Text(
                                                          "No Videos Found",
                                                          style: TextStyle(
                                                            color: settingRepo.setting.value.textColor,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
        ),
        Positioned(
          bottom: Platform.isAndroid ? 0 : 15,
          child: ValueListenableBuilder(
            valueListenable: _con.showBannerAd,
            builder: (context, adLoader, _) {
              return adLoader
                  ? Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: BannerAdWidget(AdSize.banner),
                      ),
                    )
                  : Container();
            },
          ),
        ),
        Positioned(
          bottom: Platform.isAndroid ? 0 : 15,
          child: ValueListenableBuilder(
            valueListenable: _con.showBannerAd,
            builder: (context, adLoader, _) {
              return adLoader
                  ? Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: BannerAdWidget(AdSize.banner),
                      ),
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }
}

class SettingMenu {
  static const String LOGOUT = 'Logout';
  static const String EDIT_PROFILE = 'Edit Profile';
  static const List<String> choices = <String>[EDIT_PROFILE, LOGOUT];
}
