import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';

import '../controllers/splash_screen_controller.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  static const platform = const MethodChannel('com.flutter.epic/epic');
  String dataShared = "No Data";
  SplashScreenController _con;
  BuildContext context;
  double _height;
  double _width;

  double percent = 0.0;
  Timer timer;
  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    loadData();
    timer = Timer.periodic(Duration(milliseconds: 200), (_) {
      print('Percent Update');
      setState(() {
        percent += 1;
        if (percent >= 100) {
          timer.cancel();
          // percent=0;
        }
      });
    });
    super.initState();
  }

  printHashKeyOnConsoleLog() async {
    try {
      await platform.invokeMethod("printHashKeyOnConsoleLog");
    } catch (e) {
      print(e);
    }
  }

  void loadData() async {
    try {
      await settingRepo.initSettings();
      await _con.userUniqueId();
      userRepo.getCurrentUser().whenComplete(() {
        _con.initializeVideos().whenComplete(() {
          videoRepo.dataLoaded.addListener(() async {
            if (videoRepo.dataLoaded.value) {
              if (mounted) {
                if (userRepo.currentUser.value.token != '') {
                  _con.connectUserSocket();
                }
                unawaited(videoRepo.homeCon.value.preCacheVideos());
                printHashKeyOnConsoleLog();
                setState(() {
                  percent = 100;
                  timer.cancel();
                });
                Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
              }
            }
          });
        });
      });
    } catch (e) {
      print("catch");
      print(e.toString());
    }
  }

  DateTime currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    setState(() => this.context = context);
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      body: WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          // Navigator.pop(context);
          if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "Tap again to exit an app.");
            return Future.value(false);
          }
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return Future.value(true);
        },
        child: Container(
          height: _height,
          width: _width,
          color: settingRepo.setting.value.bgColor,
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: settingRepo.setting.value.bgColor,
                  height: 40,
                  child: LiquidLinearProgressIndicator(
                    value: percent / 100,
                    valueColor: AlwaysStoppedAnimation(Colors.pink),
                    backgroundColor: settingRepo.setting.value.bgColor,
                    borderColor: settingRepo.setting.value.textColor,
                    borderWidth: 5.0,
                    borderRadius: 12.0,
                    direction: Axis.horizontal,
                    center: Text(
                      percent.toString() + "%",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: settingRepo.setting.value.textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: settingRepo.setting.value.textColor,
                  ),
                )
              ],
            ),
          ),
        ), /*Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.785,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Image.asset(
            "assets/icons/splash-logo.png",
            width: MediaQuery.of(context).size.width * 0.5,
          ),
        ),
      )*/
      ),
    );
  }

  Path _buildBoatPath() {
    return Path()
      ..moveTo(15, 120)
      ..lineTo(0, 85)
      ..lineTo(50, 85)
      ..lineTo(60, 80)
      ..lineTo(60, 85)
      ..lineTo(120, 85)
      ..lineTo(105, 120) //and back to the origin, could not be necessary #1
      ..close();
  }
}
