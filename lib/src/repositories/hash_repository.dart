import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/hash_videos_model.dart';
import '../models/search_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<HashVideosModel> hashData = new ValueNotifier(HashVideosModel());
ValueNotifier<HashVideosModel> hashVideoData = new ValueNotifier(HashVideosModel());
ValueNotifier<SearchModel> searchData = new ValueNotifier(SearchModel());
ValueNotifier<Map<String, dynamic>> adsData = new ValueNotifier({
  'android_app_id': '',
  'ios_app_id': '',
  'android_banner_app_id': '',
  'ios_banner_app_id': '',
  'android_interstitial_app_id': '',
  'ios_interstitial_app_id': '',
  'android_video_app_id': '',
  'ios_video_app_id': '',
  'video_show_on': '',
});

Future<HashVideosModel> getData(page, searchKeyword) async {
  print("hash-tag-videos");
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token);
  Uri uri = Helper.getUri('hash-tag-videos');
  uri = uri.replace(queryParameters: {
    'user_id': "0",
    'login_id': userRepo.currentUser.value.userId == null ? "0" : userRepo.currentUser.value.userId.toString(),
    "app_token": userRepo.currentUser.value.token,
    'page': page.toString(),
    'search': searchKeyword,
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          hashData.value.videos.addAll(HashVideosModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          hashData.value = HashVideosModel.fromJson(json.decode(response.body)['data']);
        }
        hashData.notifyListeners();
        return hashData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}

Future<List<dynamic>> getHashesData(page, searchKeyword) async {
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token);
  Uri uri = Helper.getUri('tag-search');
  uri = uri.replace(queryParameters: {
    'user_id': userRepo.currentUser.value.userId != null ? userRepo.currentUser.value.userId.toString() : "0",
    "app_token": userRepo.currentUser.value.token,
    'page': page.toString(),
    'search': searchKeyword
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };

    print("uri");
    print(uri);
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("append hash 1");
      print(json.decode(response.body));
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          print("append hash");
          print(json.decode(response.body));
          searchData.value.hashTags.addAll(SearchModel.fromJson(json.decode(response.body)).hashTags);
        } else {
          searchData.value = SearchModel.fromJson(json.decode(response.body)['data']);
        }
        searchData.notifyListeners();
        return searchData.value.hashTags;
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}

Future<List<dynamic>> getUsersData(page, searchKeyword) async {
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token);
  Uri uri = Helper.getUri('user-search');
  uri = uri.replace(queryParameters: {
    'user_id': userRepo.currentUser.value.userId != null ? userRepo.currentUser.value.userId.toString() : "0",
    "app_token": userRepo.currentUser.value.token,
    'page': page.toString(),
    'search': searchKeyword
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
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          searchData.value.users.addAll(SearchModel.fromJson(json.decode(response.body)).users);
        } else {
          searchData.value = SearchModel.fromJson(json.decode(response.body)['data']);
        }
        searchData.notifyListeners();
        return searchData.value.users;
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}

Future<List<Videos>> getVideosData(page, searchKeyword) async {
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token);
  Uri uri = Helper.getUri('video-search');
  uri = uri.replace(queryParameters: {
    'user_id': userRepo.currentUser.value.userId != null ? userRepo.currentUser.value.userId.toString() : "0",
    "app_token": userRepo.currentUser.value.token,
    'page': page.toString(),
    'search': searchKeyword
  });
  print("uri");
  print(uri);
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
        if (page > 1) {
          searchData.value.videos.addAll(SearchModel.fromJson(json.decode(response.body)).videos);
        } else {
          searchData.value = SearchModel.fromJson(json.decode(response.body)['data']);
        }
        searchData.notifyListeners();
        return searchData.value.videos;
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}

Future<HashVideosModel> getHashData(page, hash) async {
  print("hash-tag-videos");
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token);
  Uri uri = Helper.getUri('hash-videos');
  uri = uri.replace(queryParameters: {'user_id': userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token, 'page': page.toString(), 'hash': hash});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("JsonData  : $jsonData");
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          hashVideoData.value.videos.addAll(HashVideosModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          hashVideoData.value = HashVideosModel.fromJson(json.decode(response.body)['data']);
        }
        hashVideoData.notifyListeners();
        return hashVideoData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}

Future<SearchModel> getSearchData(page, searchKeyword) async {
  print("search");
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token);
  Uri uri = Helper.getUri('search');
  uri = uri.replace(queryParameters: {'user_id': userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token, 'page': page.toString(), 'search': searchKeyword});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    print("response search");
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print(jsonData);
      if (jsonData['status'] == 'success') {
        print("status'] == 'success");
        // if (page > 1) {
        //   searchData.value.videos.addAll(HashVideosModel.fromJson(json.decode(response.body)['data']).videos);
        // } else {
        searchData.value = SearchModel.fromJson(json.decode(response.body));
        // }
        searchData.notifyListeners();
        return searchData.value;
      }
    }
  } catch (e) {
    print("eeeee");
    print(e.toString());
    return SearchModel.fromJson({});
  }
}

Future<String> getAds() async {
  Uri uri = Helper.getUri('get-ads');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("ads jsonData");
      print(jsonData);
      if (jsonData['status'] == 'success') {
        return json.encode(json.decode(response.body));
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}
