import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controllers/dashboard_controller.dart';
import '../models/route_argument.dart';
import '../repositories/video_repository.dart' as videoRepo;
import 'dashboard_view.dart';

// ignore: must_be_immutable
class RedirectPage extends StatefulWidget {
  dynamic currentTab;
  RouteArgument routeArgument;
  Widget currentPage = DashboardWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  DashboardController cont = new DashboardController();
  RedirectPage({
    Key key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      } else {
        // cont = currentTab;
        currentTab = 0;
      }
    } else {
      currentTab = 0;
    }
  }

  @override
  _RedirectPageState createState() {
    return _RedirectPageState();
  }
}

class _RedirectPageState extends State<RedirectPage> {
  DateTime currentBackPressTime;
  initState() {
    super.initState();
    _selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(RedirectPage oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = DashboardWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (videoRepo.homeCon.value != null && videoRepo.homeCon.value.pc != null && videoRepo.homeCon.value.pc.isPanelOpen) {
          print("if check will");
          videoRepo.homeCon.value.pc.close();
          return Future.value(false);
        }
        // widget.cont.pc.isPanelOpen ??

        if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tap again to exit an app.");
          return Future.value(false);
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: Scaffold(
        key: widget.scaffoldKey,
        body: widget.currentPage,
      ),
    );
  }
}
