import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../models/login_model.dart';
import '../models/user_profile_model.dart';
import '../models/videos_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<VideoModel> usersData = new ValueNotifier(VideoModel());
ValueNotifier<BlockedModel> blockedUsersData = new ValueNotifier(BlockedModel());
ValueNotifier<LoginData> currentUser = new ValueNotifier(LoginData());
ValueNotifier<String> errorString = new ValueNotifier("");
ValueNotifier<LoginData> socialUserProfile = new ValueNotifier(LoginData());
ValueNotifier<UserProfileModel> userProfile = new ValueNotifier(UserProfileModel());
ValueNotifier<UserProfileModel> myProfile = new ValueNotifier(UserProfileModel());

Future<bool> ifEmailExists(String email) async {
  print("ifEmailExists");
  print(email);
  Uri url = Helper.getUri('is-email-exist');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({"email": email}),
  );
  if (response.statusCode == 200) {
    print("response.body");
    print(response.body);
    print("json.decode(response.body)['isEmailExist']");
    print(json.decode(response.body)['isEmailExist']);
    print(json.decode(response.body)['status']);
    if (json.decode(response.body)['status'] == "success") {
      errorString.value = "";
      errorString.notifyListeners();

      if (json.decode(response.body)['isEmailExist'] == 1) {
        return true;
      } else {
        print("isEmailExist");
        print(json.decode(response.body)['isEmailExist']);
        return false;
      }
    } else {
      return false;
    }
  } else {
    throw new Exception(response.body);
  }
}

Future<String> register(userProfile) async {
  print("userProfile");
  print(userProfile);
  Uri url = Helper.getUri('register');
  Map<String, String> headers = {
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  FormData formData = FormData.fromMap(userProfile);
  if (userProfile['profile_pic_file'] == null || userProfile['profile_pic_file'] == '') {
  } else {
    String fileName = userProfile['profile_pic_file'].split('/').last;
    print("fileName" + fileName);
    formData = FormData.fromMap({
      'fname': (userProfile['fname'] == '' || userProfile['fname'] == null) ? socialUserProfile.value.name.split(" ")[0] : userProfile['fname'],
      'lname': (userProfile['lname'] == '' || userProfile['lname'] == null) ? socialUserProfile.value.name.split(" ")[1] : userProfile['lname'],
      'email': (userProfile['email'] == '' || userProfile['email'] == null) ? socialUserProfile.value.email : userProfile['email'],
      'password': userProfile['password'],
      'confirm_password': userProfile['confirm_password'],
      'username': userProfile['username'],
      'time_zone': userProfile['time_zone'],
      'login_type': userProfile['login_type'],
      'gender': userProfile['gender'],
      'profile_pic': userProfile['profile_pic'],
      "profile_pic_file": await MultipartFile.fromFile(userProfile['profile_pic_file'], filename: fileName),
    });
  }
  // try {
  print(formData);
  print(url.toString());
  var response = await Dio().post(url.toString(),
      options: Options(
        headers: headers,
      ),
      data: formData,
      queryParameters: {"user_id": userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token});

  print(response.data);
  /*final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(userProfile),
  );*/
/*  if (response.statusCode == 200) {
    print("setCurrentUser(response.data)");
    print(response.data);
    print(json.encode(response.data));
    // setCurrentUser(json.encode(response.data));
    setCurrentUser(response.data.toString());
    currentUser.value = LoginData.fromJson(json.decode(json.decode(response.data)['content']));
  } else {
    print("errrosa");
    throw new Exception(response.data);
  }*/
  print("response register");
  print(response.data);
  // return json.encode(json.decode(response.data));
  return json.encode(response.data);
  // } catch (e) {
  //   print("error register $e");
  //   return json.encode({'status': 'failed', 'msg': 'There is some error'});
  // }
}

Future<bool> socialLogin(userProfile, timezone, type) async {
  Uri url = Helper.getUri('register-social');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(LoginData().toFBMap(userProfile, timezone, type)),
  );
  if (response.statusCode == 200) {
    print("response.body");
    print(response.body);
    if (json.decode(response.body)['status'] == "success") {
      errorString.value = "";
      errorString.notifyListeners();
      if (json.decode(response.body)['isRecord'] == null) {
        setCurrentUser(response.body);
        currentUser.value = LoginData.fromJson(json.decode(response.body)['content']);
        currentUser.notifyListeners();
      } else {
        print("response.body else");
        socialUserProfile.value = LoginData.fromJson(json.decode(response.body)['content']);
        socialUserProfile.notifyListeners();
        return false;
      }
    } else {
      print("errorstring");
      errorString.value = "Your Account is deactivated";
      errorString.notifyListeners();
      print("errorstring1");
      return false;
    }
  } else {
    throw new Exception(response.body);
  }

  return true;
}

Future<String> socialRegister(userProfile) async {
  print("socialRegister");
  print(userProfile);
  print(socialUserProfile.value);
  Uri url = Helper.getUri('social-register');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  FormData formData = FormData.fromMap(userProfile);
  if (userProfile['profile_pic_file'] != null) {
    String fileName = userProfile['profile_pic_file'].split('/').last;
    print("fileName" + fileName);
    formData = FormData.fromMap({
      'fname': (userProfile['fname'] == '' || userProfile['fname'] == null) ? socialUserProfile.value.name.split(" ")[0] : userProfile['fname'],
      'lname': (userProfile['lname'] == '' || userProfile['lname'] == null) ? socialUserProfile.value.name.split(" ")[1] : userProfile['lname'],
      'email': (userProfile['email'] == '' || userProfile['email'] == null) ? socialUserProfile.value.email : userProfile['email'],
      'password': userProfile['password'],
      'confirm_password': userProfile['confirm_password'],
      'username': userProfile['username'],
      'time_zone': userProfile['time_zone'],
      'login_type': userProfile['login_type'],
      'gender': userProfile['gender'],
      'profile_pic': userProfile['profile_pic'],
      "profile_pic_file": await MultipartFile.fromFile(userProfile['profile_pic_file'], filename: fileName),
    });
  }
  try {
    print(formData);
    print(url.toString());
    var response = await Dio().post(url.toString(),
        options: Options(
          headers: headers,
        ),
        data: formData,
        queryParameters: {"user_id": userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token});

    print(response.data);
    /*final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(userProfile),
  );*/
/*  if (response.statusCode == 200) {
    print("setCurrentUser(response.data)");
    print(response.data);
    print(json.encode(response.data));
    // setCurrentUser(json.encode(response.data));
    setCurrentUser(response.data.toString());
    currentUser.value = LoginData.fromJson(json.decode(json.decode(response.data)['content']));
  } else {
    print("errrosa");
    throw new Exception(response.data);
  }*/

    return json.encode(response.data);
  } catch (e) {
    return json.encode({'status': 'failed', 'msg': 'There is some error'});
    print("error registerSocial ${e.toString()}");
  }
}

Future<String> getEulaAgreement() async {
  Uri uri = Helper.getUri('end-user-license-agreement');
  uri = uri.replace(queryParameters: {
    'app_token': userRepo.currentUser.value.token,
    "user_id": userRepo.currentUser.value.userId.toString(),
  });

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  var response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    if (jsonData['status'] == 'success') {
      return json.encode(json.decode(response.body)['data']);
    }
  }
}

Future<bool> checkEulaAgreement() async {
  Uri uri = Helper.getUri('get-eula-agree');
  uri = uri.replace(queryParameters: {
    'app_token': userRepo.currentUser.value.token,
    "user_id": userRepo.currentUser.value.userId.toString(),
  });

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  var response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    print("jsonDataCheck");
    print(jsonData);
    if (jsonData['status'] == 'success') {
      if (jsonData['eulaAgree'] == 1) {
        return true;
      } else {
        return false;
      }
    }
  }
  // return false;
}

Future<bool> agreeEula() async {
  Uri uri = Helper.getUri('update-eula-agree');
  uri = uri.replace(queryParameters: {
    'app_token': userRepo.currentUser.value.token,
    "user_id": userRepo.currentUser.value.userId.toString(),
  });

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  var response = await http.post(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    print("agreeEula");
    print(jsonData);
    if (jsonData['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }
  // return false;
}

Future<VideoModel> getUsers(page, searchKeyword) async {
  print("getUsers");
  Uri uri = Helper.getUri('most-viewed-video-users');
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token.toString());
  uri = uri.replace(queryParameters: {"user_id": userRepo.currentUser.value.userId.toString(), 'app_token': userRepo.currentUser.value.token, 'page': page.toString(), 'search': searchKeyword});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("user search jsonData");
      print(jsonData);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          usersData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          usersData.value = VideoModel.fromJson(json.decode(response.body)['data']);
        }
        usersData.notifyListeners();
        return usersData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    VideoModel.fromJson({});
  }
}

Future<String> followUnfollowUser(userId) async {
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

Future<String> blockUser(userId) async {
  Uri url = Helper.getUri('block-user');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({"blocked_by": userRepo.currentUser.value.userId.toString(), "user_id": userId.toString(), "app_token": userRepo.currentUser.value.token}),
  );
  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<UserProfileModel> getUserProfile(userId, page) async {
  Uri uri = Helper.getUri('fetch-user-info');
  uri = uri.replace(queryParameters: {"user_id": userId.toString(), 'login_id': userRepo.currentUser.value.userId.toString(), 'page': page.toString()});
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
        print("json.decode(response.body)['data']");
        print(json.decode(response.body)['data']);
        if (page > 1) {
          userProfile.value.userVideos.addAll(UserProfileModel.fromJson(json.decode(response.body)['data']).userVideos);
        } else {
          userProfile.value = UserProfileModel.fromJson(json.decode(response.body)['data']);
        }
        print("userProfile.value.userVideos");
        print(userProfile.value.userVideos);
        userProfile.notifyListeners();
        return userProfile.value;
      }
    }
  } catch (e) {
    print(e.toString());
    UserProfileModel.fromJson({});
  }
}

Future<BlockedModel> getBlockedUsers(page) async {
  if (page == 1) {
    blockedUsersData.value = BlockedModel.fromJson({});
    blockedUsersData.notifyListeners();
  }

  Uri uri = Helper.getUri('blocked-users-list');
  uri = uri.replace(queryParameters: {
    'user_id': userRepo.currentUser.value.userId.toString(),
    "app_token": userRepo.currentUser.value.token,
    'page': page.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    print("response.body 1");
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          blockedUsersData.value.users.addAll(BlockedModel.fromJson(json.decode(response.body)['blockList']).users);
        } else {
          blockedUsersData.value = BlockedModel.fromJson(json.decode(response.body)['blockList']);
        }
        usersData.notifyListeners();
        return blockedUsersData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    FollowingModel.fromJson({});
  }
}

Future<UserProfileModel> getMyProfile(page) async {
  Uri uri = Helper.getUri('fetch-login-user-info');
  uri = uri.replace(queryParameters: {'user_id': userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token, 'page': page.toString()});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.post(uri, headers: headers);
    print("response profile");
    print(response.body.toString());
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        print(json.encode(json.decode(response.body)['data']));
        if (page > 1) {
          myProfile.value.userVideos.addAll(UserProfileModel.fromJson(json.decode(response.body)['data']).userVideos);
        } else {
          myProfile.value = UserProfileModel.fromJson(json.decode(response.body)['data']);
        }
        myProfile.notifyListeners();
        return myProfile.value;
      }
    }
  } catch (e) {
    print(e.toString());
    UserProfileModel.fromJson({});
  }
}

Future<String> logout() async {
  if (currentUser.value.loginType == 'FB') {
    FacebookLogin facebookSignIn = new FacebookLogin();
    await facebookSignIn.logOut();
  } else if (currentUser.value.loginType == 'G') {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  } else {}
  currentUser.value = new LoginData();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
  await prefs.remove('EULA_agree');
  currentUser.notifyListeners();
}

void setCurrentUser(jsonString) async {
  if (json.decode(jsonString)['content'] != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'current_user',
      json.encode(json.decode(jsonString)['content']),
    );
  }
}

Future<LoginData> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    String prefCurrentUser = await prefs.get('current_user');
    print("prefCurrentUser");
    print(prefCurrentUser);
    currentUser.value = LoginData.fromJson(json.decode(prefCurrentUser));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<String> userUniqueId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Uri uri = Helper.getUri('get-unique-id');
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
        prefs.setString("unique_id", jsonData['unique_token']);
        return json.encode(json.decode(response.body));
      }
    }
  } catch (e) {
    print(e.toString());
    UserProfileModel.fromJson({});
  }
}

Future<String> login(data) async {
  print("login data");
  print(data);
  Uri url = Helper.getUri('login');
  Map<String, String> headers = {
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: data,
  );
  print("response login");
  print(response.body);
  // .then((value) {
  // return json.encode(json.decode(response.body));
  return response.body;
  // });
}

Future<String> forgotPassword(data) async {
  print("Forgot Password");
  print(data);
  Uri url = Helper.getUri('forgot-password');
  Map<String, String> headers = {
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: data,
  );
  print("response login");
  print(response.body);
  // .then((value) {
  // return json.encode(json.decode(response.body));
  return response.body;
  // });
}

Future<String> updateForgotPassword(data) async {
  print("Update Forgot Password");
  print(data);
  Uri url = Helper.getUri('update-forgot-password');
  Map<String, String> headers = {
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: data,
  );
  print("response updateForgotPassword");
  print(response.body);
  // .then((value) {
  // return json.encode(json.decode(response.body));
  return response.body;
  // });
}

Future<String> verifyOtp(data) async {
  print("data");
  print(data);
  Uri url = Helper.getUri('verify-otp');
  Map<String, String> headers = {
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: data,
  );
  return response.body;
}

Future<String> resendOtp(data) async {
  print("data");
  print(data);
  Uri url = Helper.getUri('resend-otp');
  Map<String, String> headers = {
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: data,
  );
  return json.encode(json.decode(response.body));
}
