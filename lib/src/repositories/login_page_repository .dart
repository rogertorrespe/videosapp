import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/login_screen_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<LoginScreenData> LoginPageData =
    new ValueNotifier(LoginScreenData());

Future<LoginScreenData> fetchLoginPageInfo() async {
  Uri uri = Helper.getUri('app-login');
  uri = uri.replace(queryParameters: {});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        print("loginPageData");
        print(json.decode(response.body)['data']);
        LoginPageData.value =
            LoginScreenData.fromJSON(json.decode(response.body)['data']);
        LoginPageData.notifyListeners();
        return LoginPageData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    return LoginScreenData.fromJSON({});
  }
}

Future<String> update(data) async {
  Uri url = Helper.getUri('user-verify');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  print("update data");
  print(data);
  String fileName1 = data['document1'].split('/').last;

  print("fileName" + fileName1);
  Map<String, dynamic> submitData = {
    "name": data['name'],
    "address": data['address'],
    "document1":
        await MultipartFile.fromFile(data['document1'], filename: fileName1),
  };
  if (data['document2'] != null) {
    String fileName2 = data['document2'].split('/').last;
    submitData["document2"] =
        await MultipartFile.fromFile(data['document2'], filename: fileName2);
  }

  FormData formData = FormData.fromMap(submitData);
  var response = await Dio().post(url.toString(),
      options: Options(
        headers: headers,
      ),
      data: formData,
      queryParameters: {
        "user_id": userRepo.currentUser.value.userId.toString(),
        "app_token": userRepo.currentUser.value.token
      });
  print("response data");
  print(response.data);
  if (response.statusCode == 200) {
    /*prefs.setString(
      'current_user',
      json.encode(json.decode(response.data)['data']),
    );
    userRepo.currentUser.value =
        LoginData.fromJson(json.decode(await prefs.get('current_user')));
    userRepo.currentUser.notifyListeners();*/
    return json.encode(response.data);
  } else {
    print("error here");
    throw new Exception(response.data);
  }
}
