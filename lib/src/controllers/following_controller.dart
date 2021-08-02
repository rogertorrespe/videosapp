import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../repositories/following_repository.dart' as followRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'dashboard_controller.dart';

class FollowingController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  ScrollController scrollController;
  bool showLoader = false;
  bool showLoadMore = true;
  int curIndex = 0;
  int followUserId = 0;
  String searchKeyword = '';
  bool followUnfollowLoader = false;
  var searchController = TextEditingController();
  DashboardController homeCon;
  UserController userCon;

  bool noRecord = false;
  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_loginPage');
    super.initState();
  }

  followingUsers(userId, page) async {
    homeCon = videoRepo.homeCon.value;
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    followRepo.followingUsers(userId, page, searchKeyword).then((userValue) {
      showLoader = false;
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            followingUsers(userId, page);
          }
        }
      });
    });
  }

  followers(userId, page) async {
    homeCon = videoRepo.homeCon.value;
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    followRepo.followers(userId, page, searchKeyword).then((userValue) {
      showLoader = false;
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            followingUsers(userId, page);
          }
        }
      });
    });
  }

  Future<void> followUnfollowUser(userId, i) async {
    userCon = UserController();
    setState(() {});
    followUnfollowLoader = true;
    followRepo.followUnfollowUser(userId).then((value) {
      followUnfollowLoader = false;
      var response = json.decode(value);
      if (response['status'] == 'success') {
        followRepo.usersData.value.users[i].followText = response['followText'];
        followRepo.usersData.notifyListeners();
        userCon.refreshMyProfile();
        videoRepo.homeCon.value.getFollowingUserVideos();
        videoRepo.homeCon.notifyListeners();
      }
    }).catchError((e) {
      showLoader = false;
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text("There are som error"),
      ));
    });
  }

  friendsList(page) async {
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    followRepo.friendsList(page, searchKeyword).then((userValue) {
      if (userValue.totalRecords == 0 && searchKeyword != "") {
        noRecord = true;
      } else {
        noRecord = false;
      }
      showLoader = false;
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            friendsList(page);
          }
        }
      });
    });
  }
}
