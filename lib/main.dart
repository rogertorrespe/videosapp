import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'routes.dart';
import 'src/repositories/settings_repository.dart' as settingRepo;
import 'src/repositories/video_repository.dart' as videoRepo;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    // if (inDebug) return ErrorWidget(details.exception);
    // In release builds, show a yellow-on-blue message instead:
    return Material(
      child: Container(
        alignment: Alignment.center,
        color: settingRepo.setting.value.bgColor,
        child: InkWell(
          onTap: () {
            videoRepo.dataLoaded.value = true;
            videoRepo.homeCon.value.showHomeLoader.value = false;
          },
          child: Text(
            "There's some error",
            style: TextStyle(color: settingRepo.setting.value.headingColor),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  };
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await GlobalConfiguration().loadFromAsset("configuration");
  HttpOverrides.global = new MyHttpOverrides();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: '${GlobalConfiguration().get('app_name')}',
      navigatorObservers: [routeObserver],
      initialRoute: '/splash-screen',
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ProductSans',
        primaryColor: Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(elevation: 0, foregroundColor: Colors.white),
        brightness: Brightness.light,
        accentColor: Color(0xff36C5D3),
        dividerColor: Color(0xff36C5D3).withOpacity(0.1),
        focusColor: Color(0xff36C5D3).withOpacity(1),
        hintColor: Color(0xff000000).withOpacity(0.2),
        textTheme: TextTheme(
          headline5: TextStyle(fontSize: 22.0, color: Color(0xff000000), height: 1.3),
          headline4: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Color(0xff000000), height: 1.3),
          headline3: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
            color: Color(0xff000000),
          ),
          headline2: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Color(0xff000000),
          ),
          headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w300, color: Color(0xff000000), height: 1.4),
          subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Color(0xff000000), height: 1.3),
          headline6: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: Color(0xff000000), height: 1.3),
          bodyText2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Color(0xff000000), height: 1.2),
          bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Color(0xff000000), height: 1.3),
          caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: Color(0xff000000).withOpacity(0.5), height: 1.2),
        ),
      ),
    );
  }
}
