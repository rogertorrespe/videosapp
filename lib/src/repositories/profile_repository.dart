import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../models/login_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<EditProfileModel> usersProfileData = new ValueNotifier(EditProfileModel());

Future<EditProfileModel> fetchLoggedInUserInformation() async {
  usersProfileData.value = EditProfileModel.fromJson({});
  usersProfileData.notifyListeners();

  Uri uri = Helper.getUri('user_information');
  uri = uri.replace(queryParameters: {
    'user_id': userRepo.currentUser.value.userId.toString(),
    "app_token": userRepo.currentUser.value.token,
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        usersProfileData.value = EditProfileModel.fromJson(json.decode(response.body)['content']);
        usersProfileData.notifyListeners();
        //print(json.encode(usersProfileData.value);
        return usersProfileData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    EditProfileModel.fromJson({});
  }
}

Future<String> updateProfilePic(file) async {
  Uri uri = Helper.getUri('update_profile_pic');
  try {
    String fileName = file.path.split('/').last;
    print("fileName" + fileName);
    FormData formData = FormData.fromMap({
      "profile_pic": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    var response = await Dio().post(uri.toString(),
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': '${GlobalConfiguration().get('api_user')}',
            'KEY': '${GlobalConfiguration().get('api_key')}',
          },
        ),
        data: formData,
        queryParameters: {"user_id": userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token});
    if (response.statusCode == 200) {
      print(response.data);
      if (response.data['status'] == 'success') {
        return json.encode(response.data);
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<String> update(data) async {
  print("print data");
  print(data);
  print("data['mobile']");
  print(data['mobile']);
  if (data['mobile'] == null) {
    data['mobile'] = "";
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Uri url = Helper.getUri('update_user_information');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(data),
  );
  print("response.body");
  print(response.body);
  print(json.decode(response.body)['status']);
  if (response.statusCode == 200 && json.decode(response.body)['status'] == 'success') {
    prefs.setString(
      'current_user',
      json.encode(json.decode(response.body)['data']),
    );
    userRepo.currentUser.value = LoginData.fromJson(json.decode(prefs.get('current_user')));
    userRepo.currentUser.notifyListeners();
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> changePassword(data) async {
  Uri url = Helper.getUri('change-password');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(data),
  );
  print("response.body");
  print(response.body);
  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}
