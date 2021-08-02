import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/dashboard_controller.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<DashboardController> homeCon = new ValueNotifier(DashboardController());
ValueNotifier<bool> dataLoaded = new ValueNotifier(false);
ValueNotifier<bool> firstLoad = new ValueNotifier(true);
ValueNotifier<VideoModel> videosData = new ValueNotifier(VideoModel());
ValueNotifier<List<String>> watchedVideos = new ValueNotifier([]);
ValueNotifier<VideoModel> followingUsersVideoData = new ValueNotifier(VideoModel());
ValueNotifier<bool> isOnHomePage = new ValueNotifier(true);

Future<VideoModel> getVideos(page, [obj]) async {
  Uri uri = Helper.getUri('get-videos');
  uri = uri.replace(queryParameters: {
    "page_size": '10',
    "page": page.toString(),
    "user_id": obj != null
        ? (obj['userId'] == null)
            ? '0'
            : obj['userId'].toString()
        : '0',
    "video_id": obj != null
        ? (obj['videoId'] == null)
            ? '0'
            : obj['videoId'].toString()
        : '0',
    "login_id": userRepo.currentUser.value.userId == null ? '0' : userRepo.currentUser.value.userId.toString(),
  });
  print("Fetch URI $uri");
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        print(jsonData.toString());
        if (page > 1) {
          videosData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          videosData.value = null;
          videosData.notifyListeners();
          videosData.value = VideoModel.fromJson(json.decode(response.body)['data']);
        }
        videosData.notifyListeners();
        return videosData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    VideoModel.fromJson({});
  }
}

Future<VideoModel> getFollowingUserVideos(page) async {
  print("getFollowingUserVideos");
  Uri uri = Helper.getUri('get-videos');
  uri = uri.replace(queryParameters: {
    "page_size": '10',
    "page": page.toString(),
    "login_id": userRepo.currentUser.value.userId == null ? '0' : userRepo.currentUser.value.userId.toString(),
    "following": '1',
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("json.decode(response.body)['data']");
      print(json.encode(VideoModel.fromJson(json.decode(response.body)['data']).videos));
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          followingUsersVideoData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          followingUsersVideoData.value = null;
          followingUsersVideoData.notifyListeners();
          followingUsersVideoData.value = VideoModel.fromJson(json.decode(response.body)['data']);
        }
        followingUsersVideoData.notifyListeners();
        return followingUsersVideoData.value;
      }
    }
  } catch (e) {
    print("ERRORSSS: " + e.toString());
    VideoModel.fromJson({});
  }
}

Future<bool> updateLike(int videoId) async {
  Uri uri = Helper.getUri('video-like');
  uri = uri.replace(queryParameters: {"user_id": userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token, "video_id": videoId.toString()});

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var resposne = await http.post(uri, headers: headers);
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<String> followUnfollowUser(Video videoObj) async {
  print("followUnfollowUser video repo");
  Uri url = Helper.getUri('follow-unfollow-user');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({"follow_by": userRepo.currentUser.value.userId.toString(), "follow_to": videoObj.userId.toString(), "app_token": userRepo.currentUser.value.token}),
  );

  if (response.statusCode == 200) {
    print(json.encode(json.decode(response.body)));
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> submitReport(Video videoObj, selectedType, description) async {
  Uri url = Helper.getUri('submit-report');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({
      "user_id": userRepo.currentUser.value.userId.toString(),
      "video_id": videoObj.videoId.toString(),
      "app_token": userRepo.currentUser.value.token,
      "type": selectedType,
      "description": description
    }),
  );

  if (response.statusCode == 200) {
    print(json.encode(json.decode(response.body)));
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> incVideoViews(Video videoObj) async {
  String userVideoId = userRepo.currentUser.value.userId != null ? userRepo.currentUser.value.userId.toString() : "";
  String userVideo = videoObj.videoId.toString() + userVideoId;
  if (!watchedVideos.value.contains(userVideo)) {
    watchedVideos.value.add(userVideo);
    watchedVideos.notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uniqueToken = prefs.getString("unique_id");
    print("uniqueToken $uniqueToken");
    Uri url = Helper.getUri('video-views');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    Map<String, dynamic> data = {};
    data["unique_token"] = uniqueToken;
    if (userRepo.currentUser.value.userId != null) {
      data["user_id"] = userRepo.currentUser.value.userId;
    }

    data["video_id"] = videoObj.videoId.toString();
    print("body Data");
    print(data);
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print(json.decode(response.body).toString());
      if (!homeCon.value.showFollowingPage.value) {
        videosData.value.videos.elementAt(homeCon.value.swiperIndex).totalViews = json.decode(response.body)['total_views'];
        videosData.notifyListeners();
      } else {
        followingUsersVideoData.value.videos.elementAt(homeCon.value.swiperIndex2).totalViews = json.decode(response.body)['total_views'];
        followingUsersVideoData.notifyListeners();
      }
      return json.encode(
        json.decode(response.body),
      );
    } else {
      throw new Exception(response.body);
    }
  }
}

Future<String> getWatermark() async {
  Uri uri = Helper.getUri('get-watermark');
  String watermark = "";
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("Watermark $jsonData");
      if (jsonData['status'] == 'success') {
        watermark = jsonData['watermark'];
      }
    }
  } catch (e) {
    print(e.toString());
  }
  return watermark;
}

deleteVideo(videoId) async {
  Uri uri = Helper.getUri('delete-video');
  String watermark = "";
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var body = json.encode({
      'app_token': userRepo.currentUser.value.token,
      "user_id": userRepo.currentUser.value.userId.toString(),
      "video_id": videoId,
    });
    print("delete Request");
    print(body);
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
      body: body,
    );
    print("response.body");
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        userRepo.myProfile.value.userVideos.removeWhere((item) => item.videoId == videoId);
        userRepo.myProfile.notifyListeners();
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

deleteComment(commentId, videoId) async {
  Uri uri = Helper.getUri('delete-comment');

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var body = json.encode({
      'app_token': userRepo.currentUser.value.token,
      "user_id": userRepo.currentUser.value.userId.toString(),
      "comment_id": commentId,
      "video_id": videoId,
    });
    print("delete Request");
    print(body);
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
      body: body,
    );
    print("response.body");
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        homeCon.value.comments.removeWhere((item) => item.commentId == commentId);
        homeCon.value.loadMoreUpdateView.value = true;
        homeCon.value.loadMoreUpdateView.notifyListeners();
        if (!homeCon.value.showFollowingPage.value) {
          videosData.value.videos.elementAt(homeCon.value.swiperIndex).totalComments = videosData.value.videos.elementAt(homeCon.value.swiperIndex).totalComments - 1;
        } else {
          followingUsersVideoData.value.videos.elementAt(homeCon.value.swiperIndex2).totalComments = followingUsersVideoData.value.videos.elementAt(homeCon.value.swiperIndex2).totalComments - 1;
        }
        homeCon.notifyListeners();
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<String> editVideo(videoId, videoDescription, privacy) async {
  Uri uri = Helper.getUri('update-video-description');
  String watermark = "";
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var body = json.encode({
      'app_token': userRepo.currentUser.value.token,
      "user_id": userRepo.currentUser.value.userId.toString(),
      "video_id": videoId,
      "description": videoDescription,
      "privacy": privacy,
    });
    print("Update video Request");
    print(body);
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
      body: body,
    );
    print("response.body");
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        await userRepo.getMyProfile(1);
        return "Yes";
      } else {
        return "No";
      }
    }
  } catch (e) {
    print(e.toString());
    return "No";
  }
}
