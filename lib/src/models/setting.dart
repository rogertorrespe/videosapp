// import 'dart:ui';

import 'package:flutter/material.dart';

import '../helpers/helper.dart';

class Setting {
  Color bgColor = Colors.black;
  Color accentColor;
  Color textColor = Colors.white;
  Color buttonColor;
  Color buttonTextColor;
  Color inactiveButtonColor;
  Color inactiveButtonTextColor;
  Color senderMsgColor;
  Color senderMsgTextColor;
  Color myMsgColor;
  Color myMsgTextColor;
  Color headingColor;
  Color subHeadingColor;
  Color iconColor;
  Color dashboardIconColor;
  Color gridItemBorderColor;
  double gridBorderRadius;
  Color dividerColor;
  Color dpBorderColor;
  List<String> videoTimeLimits;

  Setting();
  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    print("Setting.fromJSON");
    print(jsonMap['gridBorderRadius']);
    print(jsonMap['videoTimeLimits']);
    print(jsonMap['videoTimeLimits'].split(','));

    try {
      bgColor = Helper.getColor(jsonMap['bgColor'] ?? '#000000');
      accentColor = Helper.getColor(jsonMap['accentColor'] ?? '#cecece');
      textColor = Helper.getColor(jsonMap['textColor'] ?? '#fafafa');
      buttonColor = Helper.getColor(jsonMap['buttonColor'] ?? '#e91e63');
      buttonTextColor = Helper.getColor(jsonMap['buttonTextColor'] ?? '#ffffff');
      inactiveButtonColor = Helper.getColor(jsonMap['buttonColor'] ?? '#e91e63');
      inactiveButtonTextColor = Helper.getColor(jsonMap['buttonTextColor'] ?? '#ffffff');
      senderMsgColor = Helper.getColor(jsonMap['senderMsgColor'] ?? '#9e0202');
      senderMsgTextColor = Helper.getColor(jsonMap['senderMsgTextColor'] ?? '#ffe5e5');
      myMsgColor = Helper.getColor(jsonMap['myMsgColor'] ?? '#a4dded');
      myMsgTextColor = Helper.getColor(jsonMap['myMsgTextColor'] ?? '#ffffff');
      headingColor = Helper.getColor(jsonMap['headingColor'] ?? '#e25822');
      subHeadingColor = Helper.getColor(jsonMap['subHeadingColor'] ?? '#ffffff');
      iconColor = Helper.getColor(jsonMap['iconColor'] ?? '#ffc0cb');
      dashboardIconColor = Helper.getColor(jsonMap['dashboardIconColor'] ?? '#fc9797');
      gridItemBorderColor = Helper.getColor(jsonMap['gridItemBorderColor'] ?? '#6cf58e');
      gridBorderRadius = jsonMap['gridBorderRadius'] == null ? 0 : double.parse(jsonMap['gridBorderRadius']);
      dividerColor = Helper.getColor(jsonMap['dividerColor'] ?? '#70ff94');
      dpBorderColor = Helper.getColor(jsonMap['accentColor'] ?? '#ffffff');
      videoTimeLimits = jsonMap['videoTimeLimits'] != null ? jsonMap['videoTimeLimits'].split(',') : ["15", "30", "60"];
    } catch (e) {
      print("error in fetching settings $e");
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["bgColor"] = bgColor;
    map["accentColor"] = accentColor;
    map["textColor"] = textColor;
    map["buttonColor"] = buttonColor;
    map["buttonTextColor"] = buttonTextColor;
    map["inactiveButtonColor"] = inactiveButtonColor;
    map["inactiveButtonTextColor"] = inactiveButtonTextColor;
    map["senderMsgColor"] = senderMsgColor;
    map["senderMsgTextColor"] = senderMsgTextColor;
    map["myMsgColor"] = myMsgColor;
    map["myMsgTextColor"] = myMsgTextColor;
    map["headingColor"] = headingColor;
    map["subHeadingColor"] = subHeadingColor;
    map["iconColor"] = iconColor;
    map["dashboardIconColor"] = dashboardIconColor;
    map["gridItemBorderColor"] = gridItemBorderColor;
    map["gridBorderRadiusColor"] = gridBorderRadius;
    map["dividerColor"] = dividerColor;
    map["dpBorderColor"] = dpBorderColor;
    map["videoTimeLimit"] = videoTimeLimits.join(',');
    return map;
  }
}
