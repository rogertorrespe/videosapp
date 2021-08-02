import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import '../helpers/helper.dart';
import '../models/user_profile_model.dart';
import '../repositories/user_repository.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RecordingView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  RecordingView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _RecordingViewState createState() => _RecordingViewState();
}

class _RecordingViewState extends StateMVC<RecordingView> {
  double _upperValue = 0;
  double _upperValue2 = 50;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: userProfile,
        builder: (context, UserProfileModel _userProfile, _) {
          return ModalProgressHUD(
            inAsyncCall: false,
            progressIndicator: Helper.showLoaderSpinner(Colors.white),
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomPadding: false,
                resizeToAvoidBottomInset: true,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(45.0),
                  child: AppBar(
                    title: Text(
                      "Recording",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          size: 18, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    backgroundColor: Color(0XFF313131),
                    centerTitle: true,
                  ),
                ),
                body: Container(
                  color: Color(0XFF3d3d3d),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Wild",
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Animals",
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color(0XFF808080),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/images/mic.gif',
                            height: 150.0,
                            width: 150.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        color: Color(0XFF484848),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 0,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: FlutterSlider(
                                  values: [_upperValue],
                                  max: 100,
                                  min: 0,
                                  handler: FlutterSliderHandler(
                                    decoration: BoxDecoration(),
                                    child: Container(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(Icons.circle,
                                            size: 15, color: Colors.white)),
                                  ),
                                  disabled: true,
                                ),
                              ),
                              Expanded(
                                flex: 0,
                                child: Text(
                                  "00:30",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DoubleCircularSlider(
                              100,
                              20,
                              0,
                              selectionColor: Colors.pink[100],
                              baseColor: Colors.pink,
                              height: 150,
                              handlerColor: Colors.white,
                              sliderStrokeWidth: 6,
                              handlerOutterRadius: 6,
                            ),
                          ),
                          Expanded(
                            child: DoubleCircularSlider(
                              100,
                              60,
                              0,
                              selectionColor: Colors.indigo[100],
                              baseColor: Colors.indigo,
                              height: 150,
                              handlerColor: Colors.white,
                              sliderStrokeWidth: 6,
                              handlerOutterRadius: 6,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: FlutterSlider(
                          values: [50],
                          max: 100,
                          min: 0,
                          centeredOrigin: true,
                          handler: FlutterSliderHandler(
                            decoration: BoxDecoration(),
                            child: Container(
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.circle,
                                    size: 15, color: Colors.white)),
                          ),
                          trackBar: FlutterSliderTrackBar(
                            inactiveTrackBarHeight: 7,
                            activeTrackBarHeight: 7,
                            inactiveTrackBar: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.withOpacity(0.1),
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            activeTrackBar: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey),
                          ),
                          onDragging: (handlerIndex, lowerValue, upperValue) {
                            _upperValue2 = upperValue;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
