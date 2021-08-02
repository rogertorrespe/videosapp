import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/setting.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());

final navigatorKey = GlobalKey<NavigatorState>();

Future<Setting> initSettings() async {
  Setting _setting;
  Uri url = Helper.getUri('app-configration');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200 /* && response.headers.containsValue('application/json')*/) {
      if (json.decode(response.body)['data'] != null) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        print("ColorCode Json");
        print(json.decode(response.body)['data']);
        // await prefs.setString('settings', json.encode(json.decode(response.body)['data']));
        _setting = Setting.fromJSON(json.decode(response.body)['data']);
        setting.value = _setting;
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        setting.notifyListeners();
      }
    } else {
      print("error in query ");
    }
  } catch (e) {
    print("error in query $e");
    return Setting.fromJSON({});
  }
  return setting.value;
}
