import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidgetController extends ControllerMVC {
  VideoPlayerController controller;
  bool lights = false;
  Duration duration;
  Duration position;
  bool isEnd = false;
  bool onTap = false;
  Future<void> initializeVideoPlayerFuture;

  showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
