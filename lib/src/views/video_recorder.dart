import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../controllers/video_recorder_controller.dart';
import '../models/sound_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/sound_repository.dart' as soundRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/sound_list.dart';
import '../views/video_submit.dart';
import '../widgets/MarqueWidget.dart';

class VideoRecorder extends StatefulWidget {
  SoundData sound;

//  final CachedVideoPlayerController videoController;
//  VideoRecorder([this.soundId, this.videoController]);
  VideoRecorder({
    Key key,
    this.sound,
  }) {
    if (sound != null) {
    } else {
      sound = SoundData(soundId: 0, title: "");
    }
  }
  @override
  _VideoRecorderState createState() {
    return _VideoRecorderState();
  }
}

class _VideoRecorderState extends StateMVC<VideoRecorder> with TickerProviderStateMixin {
  VideoRecorderController _con;

  _VideoRecorderState() : super(VideoRecorderController()) {
    _con = controller;
  }

  @override
  void dispose() {
    _con.animationController.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  void initState() {
    print("sounds video recorder");
    _con.getTimeLimits();
    /*if (widget.sound != null) {
      print(widget.sound);
      _con.saveAudio(widget.sound.url);
    }*/
    /*soundRepo.currentSound.addListener(() {
      print("listen to current sound");
      if (soundRepo.currentSound.value.soundId > 0) {
        print("if listen to current sound");
        setState(() {
          soundRepo.currentSound.value = soundRepo.currentSound.value;
        });
        print(soundRepo.currentSound.value);
        _con.saveAudio(soundRepo.currentSound.value.url);
      } else {
        print("else listen to current sound");
        setState(() {
          soundRepo.currentSound.value = SoundData();
        });
      }
      print(soundRepo.currentSound.value.toJSON());
    });*/
    print("soundRepo.currentSound.value.soundId");
    print(soundRepo.currentSound.value.soundId);
    if (soundRepo.currentSound.value.soundId > 0) {
      _con.saveAudio(soundRepo.currentSound.value.url);
    }
    super.initState();
    _con.animationController = AnimationController(vsync: this, duration: Duration(seconds: _con.seconds))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _con.animationController.repeat(reverse: !_con.reverse);
          setState(() {
            _con.reverse = !_con.reverse;
          });
        }
      });

    _con.sizeAnimation = Tween<double>(begin: 70.0, end: 80.0).animate(_con.animationController);
    _con.animationController.forward();
    if (soundRepo.currentSound.value != null && soundRepo.currentSound.value.soundId > 0) {
      if (soundRepo.currentSound.value.soundId.toString() != '' || soundRepo.currentSound.value.soundId > 0) {
        /* print("_con.audioFile");
        print(_con.audioFile);
        _con.assetsAudioPlayer.open(
          Audio.file(_con.audioFile),
          autoStart: false,
        );*/
        // setState(() {
        //   _con.showLoader = true;
        // });
        Timer(Duration(milliseconds: 300), () {
          if (_con.userId > 0) {
            // _con.getSound(widget.soundId);
          }
        });
      }
    }

    unawaited(_con.loadWatermark());
  }

  /*List<SoundModel> parseSoundModel(String jsonResponse) {
    final parsed = json.decode(jsonResponse).cast<Map<String, dynamic>>();
    return parsed.map<SoundModel>((json) => SoundModel.fromJson(json)).toList();
  }*/

  Widget _thumbnailWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: _con.videoController == null
          ? Container()
          : Stack(children: <Widget>[
              SizedBox.expand(
                child: (_con.videoController == null)
                    ? Container()
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              /*
                            width: videoController.value.size?.width ?? 0,
                                height: videoController.value.size?.height ?? 0,*/
                              width: _con.videoController.value.size.width,
                              height: _con.videoController.value.size.height,
                              child: Center(
                                child: AspectRatio(
                                    aspectRatio: _con.videoController.value.aspectRatio
                                    /*videoController.value.size != null
                                          ? videoController.value.aspectRatio
                                          : 1.0*/
                                    ,
                                    child: VideoPlayer(_con.videoController)),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 50,
                right: 20,
                child: RawMaterialButton(
                  onPressed: () {
                    print("_con.thumbPath _con.videoPath ${_con.thumbPath} ${_con.videoPath},");
                    _con.videoController.pause();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoSubmit(
                          thumbPath: _con.thumbPath,
                          videoPath: _con.videoPath,
                          gifPath: _con.gifPath,
                        ),
                      ),
                    );
//                    uploadVideo();
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.check_circle,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 20,
                child: RawMaterialButton(
                  onPressed: () {
                    _con.videoController.pause();
                    /*setState(() {
                        _con.isUploading = false;
                        _con.timer.cancel();
                        _con.videoController = null;
                      });*/
                    soundRepo.currentSound = new ValueNotifier(SoundData(soundId: 0, title: ""));
                    soundRepo.currentSound.notifyListeners();
                    videoRepo.homeCon.value.showFollowingPage.value = false;
                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                    videoRepo.homeCon.value.getVideos();
                    Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.close,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
            ]),
    );
  }

  Widget publishPanel() {
    const Map<String, int> privacies = {'Public': 0, 'Private': 1, 'Only Followers': 2};
    return Stack(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Container(
            color: Colors.black,
            /*decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),*/
            height: MediaQuery.of(context).size.height,
//        color: Colors.white,
            child: Form(
              key: _con.key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                    child: Center(
                      child: Text(
                        "New Post",
                        style: TextStyle(
                          fontFamily: 'RockWellStd',
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      height: 1,
                      child: Container(
                        color: Colors.white30,
                      ),
                    ),
                  ),
                  Container(
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                  validator: _con.validateDescription,
                                  onSaved: (String val) {
                                    _con.description = val;
                                  },
                                  onChanged: (String val) {
                                    _con.description = val;
                                  },
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      wordSpacing: 2.0,
                                    ),
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pinkAccent,
                                        width: 0.5,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pinkAccent,
                                        width: 0.5,
                                      ),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                    hintText: "Enter Video Description",
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 175,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.pinkAccent, //                   <--- border color
                                          width: 0.5,
                                        ),
                                        color: Color(0xff2e2f34),
                                        borderRadius: BorderRadius.all(new Radius.circular(6.0)),
                                        image: DecorationImage(
                                          image: _con.thumbPath != '' ? AssetImage(_con.thumbPath) : AssetImage("assets/images/splash.png"),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),

                                      /* child: CachedNetworkImage(
                                      imageUrl: thumbPath,
                                      height: 175,
                                    ),*/
                                    ),
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Colors.black,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            "Privacy Setting",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * .4,
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
//                                      canvasColor: Color(0xffffffff),
                                            canvasColor: Colors.black87,
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField(
                                              isExpanded: true,
                                              hint: new Text(
                                                "Select Type",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              iconEnabledColor: Colors.white,
                                              style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                              ),
                                              value: _con.privacy,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _con.privacy = newValue;
                                                });
                                              },
                                              items: privacies
                                                  .map((text, value) {
                                                    return MapEntry(
                                                      text,
                                                      DropdownMenuItem<int>(
                                                        value: value,
                                                        child: new Text(
                                                          text,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                  .values
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: RaisedButton(
                                  color: Color(0xff15161a),
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 45,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.0),
                                      gradient: Gradients.blush,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Validate returns true if the form is valid, otherwise false.
                                    // homeCon = videoRepo.homeCon.value;
                                    soundRepo.currentSound = new ValueNotifier(SoundData(soundId: 0, title: ""));
                                    soundRepo.currentSound.notifyListeners();
                                    videoRepo.homeCon.value.showFollowingPage.value = false;
                                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                    videoRepo.homeCon.value.getVideos();
                                    Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: RaisedButton(
                                  color: Color(0xff15161a),
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 45,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.0),
                                      gradient: Gradients.blush,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Submit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Icon(
                                              Icons.send,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    FocusManager.instance.primaryFocus.unfocus();

                                    // Validate returns true if the form is valid, otherwise false.
                                    if (_con.key.currentState.validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.
                                      _con.enableVideo(context);
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          content: Text("Enter Video Description"),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        /*(_con.isUploading == true)
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(20),
                  color: Colors.black54,
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black87,
                    ),
                    width: 200,
                    height: 170,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: CircularPercentIndicator(
                              progressColor: Colors.pink,
                              percent: _con.uploadProgress,
                              radius: 120.0,
                              lineWidth: 8.0,
                              circularStrokeCap: CircularStrokeCap.round,
                              center: Text(
                                (_con.uploadProgress * 100).toStringAsFixed(2) +
                                    "%",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          */ /*Container(
                                      child: Text(
                                        (uploadProgress * 100)
                                                .toStringAsFixed(2) +
                                            " %",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 2.0,
                                      child: LinearProgressIndicator(
                                        value: uploadProgress,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),*/ /*
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container(),*/
        (_con.isProcessing == true)
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(20),
                  color: Colors.black54,
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black87,
                    ),
                    width: 200,
                    height: 170,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Container(
                              height: 90,
                              width: 90,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Processing video",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          /*Container(
                                      child: Text(
                                        (uploadProgress * 100)
                                                .toStringAsFixed(2) +
                                            " %",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 2.0,
                                      child: LinearProgressIndicator(
                                        value: uploadProgress,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),*/
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  static showLoaderSpinner() {
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

  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // CameraDescription selectedCamera = cameras[selectedCameraIdx];
    // CameraLensDirection lensDirection = selectedCamera.lensDirection;
    if (size != null) {
      var deviceRatio = size.width / size.height;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black54),
      );
      return ModalProgressHUD(
        progressIndicator: showLoaderSpinner(),
        inAsyncCall: _con.showLoader,
        child: WillPopScope(
          onWillPop: () async => _con.willPopScope(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            key: _con.scaffoldKey,
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    child: Center(
                      child: Transform.scale(
                        scale:
                            (_con.controller != null && !_con.controller.value.isInitialized) ? 1 : _con.controller.value.aspectRatio / deviceRatio,
                        // scale: 1,
                        child: new AspectRatio(
                          aspectRatio: (!_con.controller.value.isInitialized) ? 1 : _con.controller.value.aspectRatio,
                          // aspectRatio: 1,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Center(
                                      child: (!_con.controller.value.isInitialized) ? CircularProgressIndicator() : _cameraPreviewWidget(),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onDoubleTap: () {
                      _con.onSwitchCamera();
                    },
                  ),
                  (_con.controller == null || !_con.controller.value.isInitialized || !_con.controller.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 35,
                          left: 0,
                          child: _cameraTogglesRowWidget(),
                        )
                      : Container(),
                  Positioned(
                    bottom: 35,
                    left: 85,
                    child: _cameraFlashRowWidget(),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _captureControlRowWidget11(),
                      ),
                    ),
                  ),
                  (_con.controller == null || !_con.controller.value.isInitialized || !_con.controller.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 110,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: getTimerLimit(),
                            ),
                          ),
                        )
                      : Container(),
                  (_con.showProgressBar)
                      ? Positioned(
                          top: 10,
                          child: LinearPercentIndicator(
                            width: MediaQuery.of(context).size.width,
                            lineHeight: 5.0,
                            animationDuration: 100,
                            percent: _con.videoProgressPercent,
                            progressColor: Color(0xffec4a63),
                          ),
                        )
                      : Container(),
                  (_con.controller == null || !_con.controller.value.isInitialized || !_con.controller.value.isRecordingVideo)
                      ? Positioned(
                          top: 30,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                child: SizedBox(
                                  width: 140.0,
                                  child: MarqueeWidget(
                                    direction: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          soundRepo.currentSound.value.title == null || soundRepo.currentSound.value.title == ""
                                              ? "Select Sound "
                                              : soundRepo.currentSound.value.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(
                                          Icons.queue_music,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SoundList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  (_con.controller != null && _con.controller.value.isInitialized && _con.controller.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 35,
                          right: 90,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox.fromSize(
                                size: Size(
                                  50,
                                  50,
                                ), // button width and height
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor: Colors.pinkAccent, // splash color
                                        onTap: () {
                                          setState(() {
                                            _con.reverse = _con.reverse;
                                          });
                                          if (!_con.videoRecorded) {
                                            _con.onResumeButtonPressed(context);
                                            _con.animationController.forward();
                                          } else {
                                            _con.onPauseButtonPressed(context);
                                            _con.animationController.stop();
                                          }
                                        },
                                        child: Container(
                                          color: settingRepo.setting.value.buttonColor,
                                          width: 50,
                                          height: 50,
                                          child: Icon(
                                            !_con.videoRecorded ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                            size: 35,
                                            color: settingRepo.setting.value.buttonTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Positioned(
                    bottom: 35,
                    right: 0,
                    child: FlatButton(
                      child: SvgPicture.asset(
                        'assets/icons/image-gallery.svg',
                        width: 40,
                        color: settingRepo.setting.value.iconColor,
                      ),
                      onPressed: () {
                        _con.uploadGalleryVideo();
                      },
//        icon: Icon(_getCameraLensIcon(lensDirection)),
                      /* label: Text(
            "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}"),*/
                    ),
                  ),
                  (_con.isUploading == true)
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black54,
                          ),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black87,
                              ),
                              width: 200,
                              height: 170,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: CircularPercentIndicator(
                                        progressColor: Colors.pink,
                                        percent: _con.uploadProgress,
                                        radius: 120.0,
                                        lineWidth: 8.0,
                                        circularStrokeCap: CircularStrokeCap.round,
                                        center: Text(
                                          (_con.uploadProgress * 100).toStringAsFixed(2) + "%",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    /*Container(
                                      child: Text(
                                        (uploadProgress * 100)
                                                .toStringAsFixed(2) +
                                            " %",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 2.0,
                                      child: LinearProgressIndicator(
                                        value: uploadProgress,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),*/
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      /*StreamBuilder<bool>(
                          stream: _loadingStreamCtrl.stream,
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            print("loadingStream");
                            print(snapshot.data);
                            if (snapshot.data == true) {
                              return GestureDetector(
                                onTap: () {
//                                _flutterVideoCompress.cancelCompression();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.black54,
                                  child: Center(
                                    child: Container(
                                      color: Colors.black,
                                      width: 100,
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset(
                                                "assets/images/gif-logo.gif"),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            SizedBox(
                                              height: 2.0,
                                              child: LinearProgressIndicator(
                                                value: uploadProgress,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        )*/
                      : Container(),
                  /*(Platform.isIOS)
                      ? Positioned(
                          top: 30,
                          left: 10,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: GestureDetector(
                                child: SizedBox(
                                  width: 35,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.close,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                      */ /*Text(
                                        "Exit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      )*/ /*
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _con.onPauseButtonPressed(context);
                                  _con.animationController.stop();
                                  if (_con.isVideoRecorded == true) {
                                    return _con.exitConfirm(context);
                                  } else {
                                    soundRepo.currentSound = new ValueNotifier(SoundData(soundId: 0, title: ""));
                                    soundRepo.currentSound.notifyListeners();
                                    videoRepo.homeCon.value.showFollowingPage.value = false;
                                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                    videoRepo.homeCon.value.getVideos();
                                    Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                      : Container(),*/
                  _con.controller != null && _con.controller.value.isInitialized && !_con.controller.value.isRecordingVideo
                      ? Positioned(
                          top: 30,
                          left: 10,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                width: 35,
                                child: ValueListenableBuilder(
                                    valueListenable: soundRepo.mic,
                                    builder: (context, bool enableMic, _) {
                                      return InkWell(
                                        child: SizedBox(
                                          width: 35,
                                          child: enableMic
                                              ? Image.asset(
                                                  "assets/icons/microphone.png",
                                                  height: 30,
                                                )
                                              : Image.asset(
                                                  "assets/icons/microphone-mute.png",
                                                  height: 30,
                                                ),
                                        ),
                                        onTap: () {
                                          soundRepo.mic.value = enableMic ? false : true;
                                          soundRepo.mic.notifyListeners();
                                          _con.onCameraSwitched(_con.cameras[_con.selectedCameraIdx]).then((void v) {});
                                        },
                                      );
                                    }),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  _thumbnailWidget(),
                  _con.videoController == null
                      ? Positioned(
                          top: 30,
                          right: 20,
                          child: GestureDetector(
                            onTap: () {
                              /*setState(() {
                                _con.isUploading = false;
                                _con.timer.cancel();
                                _con.videoController = null;
                              });*/
                              _con.willPopScope(context);
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  (_con.isProcessing == true)
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black54,
                          ),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black87,
                              ),
                              width: 200,
                              height: 170,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Processing video",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    /*Container(
                                      child: Text(
                                        (uploadProgress * 100)
                                                .toStringAsFixed(2) +
                                            " %",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      height: 2.0,
                                      child: LinearProgressIndicator(
                                        value: uploadProgress,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),*/
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      print("centerCircular");
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }

  // IconData _getCameraLensIcon(CameraLensDirection direction) {
  //   switch (direction) {
  //     case CameraLensDirection.back:
  //       return Icons.camera_rear;
  //     case CameraLensDirection.front:
  //       return Icons.camera_front;
  //     case CameraLensDirection.external:
  //       return Icons.camera;
  //     default:
  //       return Icons.device_unknown;
  //   }
  // }

  Widget _cameraPreviewWidget() {
    if (_con.controller == null || !_con.controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(_con.controller);
    }
  }

  Widget _cameraTogglesRowWidget() {
    if (_con.cameras == null) {
      return Row();
    }

    // CameraDescription selectedCamera = cameras[selectedCameraIdx];
    // CameraLensDirection lensDirection = selectedCamera.lensDirection;
    return FlatButton(
      child: SvgPicture.asset(
        'assets/icons/flip.svg',
        width: 40,
        color: settingRepo.setting.value.iconColor,
      ),
      onPressed: () {
        _con.onSwitchCamera();
      },
//        icon: Icon(_getCameraLensIcon(lensDirection)),
      /* label: Text(
            "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}"),*/
    );
  }

  Widget _cameraFlashRowWidget() {
    // commented function
    return Row();
/*//    print("cameraFlashRowWidget");
    if (cameras == null) {
      return Row();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;
    print(lensDirection);
    */ /*if (lensDirection == "CameraLensDirection.front") {
      return Row();
    }
    if (lensDirection == "CameraLensDirection.back") {*/ /*
//    print(lensDirection);
    return Container(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
        onTap: () async {
          */ /*bool hasTorch = await TorchCompat.hasLamp;
          if (hasTorch) {*/ /*
          if (!_toggleFlash) {
            FlutterTorch.turnOn();
            setState(() {
              _flashOn = "assets/icons/flash-on.png";
              _toggleFlash = true;
            });
          } else {
            FlutterTorch.turnOff();
            setState(() {
              _flashOn = "assets/icons/flash-off.png";
              _toggleFlash = false;
            });
          }
//          }
        },
        child: Container(
          child: Image.asset(
            _flashOn,
            width: 50.0,
//            height: 15.0,
          ),
        ),
      ),
    );
    */ /*} else {
      return Container(
        width: 15.0,
        height: 15.0,
      );
    }*/
  }

  Widget _captureControlRowWidget11() {
    return _con.controller != null && _con.controller.value.isInitialized
        ? !_con.controller.value.isRecordingVideo && !_con.isProcessing
            ? SizedBox.fromSize(
                size: Size(70, 70), // button width and height
                child: ClipOval(
                  child: Container(
                    color: settingRepo.setting.value.buttonColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _con.controller != null && _con.controller.value.isInitialized && !_con.controller.value.isRecordingVideo
                                ? _con.onRecordButtonPressed(context)
                                : _con.onStopButtonPressed();
                          },
                          onDoubleTap: () {
                            if (_con.controller != null && _con.controller.value.isInitialized && !_con.controller.value.isRecordingVideo) {
                              print("Camera Testing");
                            } else {
                              print("else Camera Testing");
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: SvgPicture.asset(
                                  "assets/icons/video-camera.svg",
                                  width: 50,
                                  height: 50,
                                  color: settingRepo.setting.value.iconColor,
                                ),
                              )
                              /*: AnimatedBuilder(
                            animation: _con.sizeAnimation,
                            builder: (context, child) => SvgPicture.asset(
                              "assets/icons/video-camera.svg",
                              color: settingRepo.setting.value.iconColor,
                              height: _con.sizeAnimation.value,
                              width: _con.sizeAnimation.value,
                            ),
                          )*/
                              , // icon
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : AnimatedBuilder(
                animation: _con.sizeAnimation,
                builder: (context, child) => SizedBox.fromSize(
                  size: Size(_con.sizeAnimation.value, _con.sizeAnimation.value), // button width and height
                  child: ClipOval(
                    child: Container(
                      color: settingRepo.setting.value.buttonColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _con.controller != null && _con.controller.value.isInitialized && !_con.controller.value.isRecordingVideo
                                  ? _con.onRecordButtonPressed(context)
                                  : _con.onStopButtonPressed();
                            },
                            onDoubleTap: () {
                              if (_con.controller != null && _con.controller.value.isInitialized && !_con.controller.value.isRecordingVideo) {
                                print("Camera Testing");
                              } else {
                                print("else Camera Testing");
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: SvgPicture.asset(
                                    "assets/icons/record.svg",
                                    width: 50,
                                    height: 50,
                                    color: settingRepo.setting.value.iconColor,
                                  ),
                                )
                                /*: AnimatedBuilder(
                              animation: _con.sizeAnimation,
                              builder: (context, child) => SvgPicture.asset(
                                "assets/icons/video-camera.svg",
                                color: settingRepo.setting.value.iconColor,
                                height: _con.sizeAnimation.value,
                                width: _con.sizeAnimation.value,
                              ),
                            )*/
                                , // icon
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
        : Container();
  }

  Widget getTimerLimit() {
    List<Widget> list = new List<Widget>();
    return ValueListenableBuilder(
        valueListenable: _con.videoTimerLimit,
        builder: (context, List<double> timers, _) {
          timers.length = timers.length > 5 ? 5 : timers.length;
          list = new List<Widget>();
          if (timers.length > 0) {
            for (var i = 0; i < timers.length; i++) {
              list.add(
                InkWell(
                  onTap: () {
                    print("getTextWidgets");
                    print(i);
                    if (_con.videoLength != timers[i].toDouble()) {
                      // setState(() {
                      // _con.selectedVideoFragment.value = i;
                      // _con.selectedVideoFragment.notifyListeners();
                      // });

                      setState(() {
                        _con.videoLength = timers[i] > 300 ? 300 : timers[i];
                      });
                      print(_con.videoLength);
                    }
                  },
                  child: Container(
                      margin: EdgeInsets.only(
                        right: 10,
                      ),
                      height: 35.0,
                      constraints: BoxConstraints(
                        minWidth: 35,
                      ),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: (_con.videoLength == timers[i]) ? settingRepo.setting.value.buttonColor : Colors.black38,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            (_con.videoLength == timers[i]) ? Border.all(color: Colors.white, width: 2) : Border.all(color: Colors.white70, width: 0),
                      ),
                      child: Center(
                        child: Text(
                          "${timers[i].toInt() > 300 ? 300 : timers[i].toInt()}s",
                          style: TextStyle(
                            color: (_con.videoLength == timers[i]) ? settingRepo.setting.value.buttonTextColor : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )),
                ),
              );
            }
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                height: 70,
                child: timers.length > 0
                    ? list.length > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: list,
                          )
                        : Container()
                    : Container(),
              ),
            );
          } else {
            list.add(Container());
            return Container();
          }
        });
  }
}

class VideoRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      home: VideoRecorder(),
    );
  }
}

Future<void> main() async {
  runApp(VideoRecorderApp());
}

class TrimmerView extends StatefulWidget {
  final Trimmer trimmer;
  final ValueSetter<String> onVideoSaved;
  final VoidCallback onSkip;
  final double maxLength;
  final String sound;
  final bool showSkip;
  TrimmerView({
    this.trimmer,
    this.onVideoSaved,
    this.onSkip,
    this.maxLength,
    this.sound,
    this.showSkip,
  });
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  // AssetsAudioPlayer assetsAudioPlayer = new AssetsAudioPlayer();
  bool _isPlaying = false;
  bool _progressVisibility = false;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // assetsAudioPlayer.dispose();
  }

  /*void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Video Length Alert"),
          content: new Text("Video should not exceed 15 secs"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
//                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/
  /*openAudioFile(audio) async {
    var sound = await DefaultCacheManager().getFileFromCache(audio);
    assetsAudioPlayer.open(
      Audio.file(sound.file.path),
      autoStart: false,
    );
  }*/

  Future<String> _saveVideo() async {
    setState(() {
      if (_startValue + widget.maxLength * 1000 < _endValue) {
        _endValue = _startValue + widget.maxLength * 1000;
      }
      _progressVisibility = true;
    });
    print("_startValue");
    print(_startValue);
    print("_endValue");
    print(_endValue);
    print("widget.maxLength");
    print(widget.maxLength);
    String _value;

    await widget.trimmer
        .saveTrimmedVideo(
            ffmpegCommand: " -preset ultrafast ",
            applyVideoEncoding: widget.showSkip ? false : true,
            startValue: _startValue,
            endValue: _endValue,
//            maxLength: widget.maxLength,
            customVideoFormat: '.mp4')
        .then((value) {
      setState(() {
        _progressVisibility = true;
        _value = value;
      });
    });
    return _value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: settingRepo.setting.value.bgColor,
        title: Text(" "),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                /*RaisedButton(
                  color: Color(0xff15161a),
                  padding: EdgeInsets.all(0),
                  child: Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        gradient: Gradients.blush),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            print('OUTPUT PATH: $outputPath');
                            final snackBar = SnackBar(
                              content: Text('Video Saved successfully'),
                            );
                            widget.onVideoSaved(outputPath);
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                        },
                ),*/
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: VideoViewer(),
                ),
                Center(
                  child: TrimEditor(
                    viewerHeight: 50.0,
                    // sound: widget.sound,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: Duration(seconds: widget.maxLength.toInt()),
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      print("End changed");
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      print("onChangePlaybackState $_endValue $_startValue");
                      if (_endValue - _startValue >= widget.maxLength * 1000 + 0.1) {
                        setState(() {
                          _endValue = _startValue + widget.maxLength * 1000;
                        });
                      }
                      /*if (widget.sound != "") {
                        if (assetsAudioPlayer
                                .currentPosition.value.inMilliseconds
                                .toDouble() >=
                            _endValue) {
                          assetsAudioPlayer.playOrPause();
                        }
                        if (!value) {
                          assetsAudioPlayer.pause();
                          assetsAudioPlayer.seek(Duration(seconds: 0));
                        } else {
                          assetsAudioPlayer.play();
                        }
                      }*/
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    RaisedButton(
                      color: Color(0xff15161a),
                      padding: EdgeInsets.all(0),
                      child: Container(
                        height: 35,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          color: settingRepo.setting.value.buttonColor,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                _isPlaying ? "Pause" : "Play",
                                style: TextStyle(
                                  color: settingRepo.setting.value.buttonTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'RockWellStd',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (widget.sound != "") {
                          /*if (assetsAudioPlayer.current.value == null) {
                        // AssetsAudioPlayer.allPlayers().forEach((key, value) {
                        //   value.pause();
                        // });
                        // await assetsAudioPlayer
                        //     .open(Audio.network(widget.sound), autoStart: true);
                      } else {
                        // AssetsAudioPlayer.allPlayers().forEach((key, value) {
                        //   value.pause();
                        // });
                        assetsAudioPlayer.pause();
                      }*/
                        }
                        bool playbackState = await widget.trimmer.videPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );

                        setState(() {
                          _isPlaying = playbackState;
                        });
                      },
                    ),
                    widget.showSkip
                        ? RaisedButton(
                            color: Color(0xff15161a),
                            padding: EdgeInsets.all(0),
                            child: Container(
                              height: 35,
                              width: 80,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), color: settingRepo.setting.value.buttonColor),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      "Skip",
                                      style: TextStyle(
                                        color: settingRepo.setting.value.buttonTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        fontFamily: 'RockWellStd',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onPressed: () {
                              widget.onSkip();
                            },
                          )
                        : Container(),
                    RaisedButton(
                      color: Color(0xff15161a),
                      padding: EdgeInsets.all(0),
                      child: Container(
                        height: 35,
                        width: 80,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), color: settingRepo.setting.value.buttonColor),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                "Save",
                                style: TextStyle(
                                  color: settingRepo.setting.value.buttonTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'RockWellStd',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onPressed: _progressVisibility
                          ? null
                          : () async {
                              _saveVideo().then((outputPath) {
                                print('OUTPUT PATH: $outputPath');
                                final snackBar = SnackBar(
                                  content: Text('Video Saved successfully'),
                                );
                                widget.onVideoSaved(outputPath);
                                Scaffold.of(context).showSnackBar(snackBar);
                              });
                            },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String durationToString(Duration duration) {
    String twoDigits(var n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
