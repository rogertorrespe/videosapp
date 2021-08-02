import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../controllers/dashboard_controller.dart';
import '../repositories/socket_repository.dart' as socketRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;

class SplashScreenController extends ControllerMVC {
  ValueNotifier<bool> processing = new ValueNotifier(true);
  DashboardController homeCon;
  String uniqueId;
  GlobalKey<ScaffoldState> scaffoldKey;
  IO.Socket socket;
  String url = "${GlobalConfiguration().get('node_url')}";
  Future<void> initializeVideos() async {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    await videoRepo.homeCon.value.getVideos();
    videoRepo.homeCon.notifyListeners();
  }

  connectUserSocket() async {
    print("connectUserSocket");
    try {
      socket = IO.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socketRepo.clientSocket.value = socket;
      socketRepo.clientSocket.notifyListeners();
      socket.emit("user-id", userRepo.currentUser.value.userId);
    } catch (e) {
      print("catch socket");
      print(e.toString());
    }
  }

  Future<void> userUniqueId() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      uniqueId = (pref.getString('unique_id') == null)
          ? ""
          : pref.getString('unique_id');
      if (uniqueId == "") {
        userRepo.userUniqueId().then((value) {
          var jsonData = json.decode(value);
          uniqueId = jsonData['unique_token'];
        });
      }
    }
  }
}
