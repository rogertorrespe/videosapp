import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<FollowingModel> usersData = new ValueNotifier(FollowingModel());
ValueNotifier<FollowingModel> friendsData = new ValueNotifier(FollowingModel());

Future<FollowingModel> followingUsers(userId, page, searchKeyword) async {
  if (page == 1) {
    usersData.value = FollowingModel.fromJson({});
    usersData.notifyListeners();
  }

  Uri uri = Helper.getUri('following-users-list');
  uri = uri.replace(queryParameters: {
    'login_id': userRepo.currentUser.value.userId.toString(),
    'user_id': userId.toString(),
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
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          usersData.value.users.addAll(FollowingModel.fromJson(json.decode(response.body)['data']).users);
        } else {
          usersData.value = FollowingModel.fromJson(json.decode(response.body)['data']);
        }
        usersData.notifyListeners();
        return usersData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    FollowingModel.fromJson({});
  }
}

Future<FollowingModel> followers(userId, page, searchKeyword) async {
  if (page == 1) {
    usersData.value = FollowingModel.fromJson({});
    usersData.notifyListeners();
  }

  Uri uri = Helper.getUri('followers-list');
  uri = uri.replace(queryParameters: {
    'login_id': userRepo.currentUser.value.userId.toString(),
    'user_id': userId.toString(),
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
    var response = await http.post(uri, headers: headers);
    print("response.body 1");
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          usersData.value.users.addAll(FollowingModel.fromJson(json.decode(response.body)['data']).users);
        } else {
          usersData.value = FollowingModel.fromJson(json.decode(response.body)['data']);
        }
        usersData.notifyListeners();
        return usersData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    FollowingModel.fromJson({});
  }
}

Future<String> followUnfollowUser(userId) async {
  print("followUnfollowUser repo");
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
    body: json.encode({"follow_by": userRepo.currentUser.value.userId.toString(), "follow_to": userId.toString(), "app_token": userRepo.currentUser.value.token}),
  );

  if (response.statusCode == 200) {
    print(json.encode(json.decode(response.body)));
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<FollowingModel> friendsList(page, searchKeyword) async {
  print("friends-list");
  if (page == 1) {
    usersData.value = FollowingModel.fromJson({});
    usersData.notifyListeners();
  }
  Uri uri = Helper.getUri('friends-list');
  uri = uri.replace(queryParameters: {'user_id': userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token, 'page': page.toString(), 'search': searchKeyword});
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
          friendsData.value.users.addAll(FollowingModel.fromJson(json.decode(response.body)['data']).users);
        } else {
          friendsData.value = FollowingModel.fromJson(json.decode(response.body)['data']);
        }
        friendsData.notifyListeners();
        return friendsData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    FollowingModel.fromJson({});
  }
}
