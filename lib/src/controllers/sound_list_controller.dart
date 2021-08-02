import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/sound_model.dart';
import '../repositories/sound_repository.dart' as soundRepo;

class SoundListController extends ControllerMVC {
//  Map<String, dynamic> sounds = {};
  int currentIndex;
  String currentFile;
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.withId("4234234323asdsad");
  GlobalKey<ScaffoldState> soundScaffoldKey;
  var jsonData;
  var getSoundResult;
  var getFavSoundResult;
  bool allPaused;
  int userId = 0;
  int videoId = 0;
  List<SoundData> sounds = [];
  var textController1 = TextEditingController();
  var textController2 = TextEditingController();
  String searchKeyword = '';
  String searchKeyword1 = '';
  String searchKeyword2 = '';
  String catSearchKeyword = '';
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  ScrollController scrollController;
  ScrollController scrollController1;
  ScrollController catScrollController;
  int page = 1;
  bool moreResults = true;
  Color loaderBGColor = Colors.black;
  bool showLoadMore;

  int favPage = 1;

  int catPage = 1;
  @override
  void initState() {
    soundScaffoldKey = new GlobalKey();
    super.initState();
  }

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

  selectSound(SoundData sound) {
    soundRepo.selectSound(sound);
  }

  Future<SoundModelList> getSounds([searchKeyword]) async {
    setState(() {
      showLoader = true;
    });

    if (page == 1 && searchKeyword == '') {
      scrollController = new ScrollController();
    }
    if (page > 1) {
      setState(() {
        loaderBGColor = Colors.black26;
      });
    }
    soundRepo.getData(page, searchKeyword).then((value) {
      setState(() {
        showLoader = false;
      });
      if (value.data != null && value.data.length > 0) {
        showLoadMore = true;
      } else {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        print("AddListnere");
        print(scrollController.position.pixels);
        print("  ::  ");
        print(scrollController.position.maxScrollExtent);
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          print("showLoadMore");
          print(showLoadMore);
          if (showLoadMore) {
            setState(() {
              page = page + 1;
            });
            getSounds();
          }
        }
      });
    });
  }

  Future<dynamic> setFavSounds(soundId, set) async {
    return soundRepo.setFavSound(soundId, set);
  }

  Future getFavSounds([searchKeyword]) async {
    print("getSounds");
    print(favPage);
    if (searchKeyword == null) {
      searchKeyword = "";
    }
    print(loaderBGColor.toString());
    showLoader = true;
    if (favPage == 1 && searchKeyword == '') {
      scrollController1 = new ScrollController();
    }

    if (favPage > 1) {
      setState(() {
        loaderBGColor = Colors.black26;
      });
    }
    soundRepo.getFavData(favPage, searchKeyword).then((value) {
      setState(() {
        showLoader = false;
      });
      if (value.data != null && value.data.length > 0) {
        showLoadMore = true;
      } else {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        print("AddListnere");
        print(scrollController1.position.pixels);
        print("  ::  ");
        print(scrollController1.position.maxScrollExtent);
        if (scrollController1.position.pixels == scrollController.position.maxScrollExtent) {
          print("showLoadMore");
          print(showLoadMore);
          if (showLoadMore) {
            setState(() {
              favPage = favPage + 1;
            });
            getFavSounds();
          }
        }
      });
    });
  }

  Future getCatSounds(catId, [searchKeyword]) async {
    print("getCatSounds");
    print(catPage);
    if (searchKeyword == null) {
      searchKeyword = "";
    }
    print(loaderBGColor.toString());
    showLoader = true;
    catScrollController = new ScrollController();
    if (favPage > 1) {
      setState(() {
        loaderBGColor = Colors.black26;
      });
    }
    soundRepo.getCatData(catId, catPage, searchKeyword).then((value) {
      setState(() {
        showLoader = false;
      });
      if (value.data != null && value.data.length > 0) {
        showLoadMore = true;
      } else {
        showLoadMore = false;
      }
      catScrollController.addListener(() {
        print("AddListnere");
        print(catScrollController.position.pixels);
        print("  ::  ");
        print(catScrollController.position.maxScrollExtent);
        if (catScrollController.position.pixels == catScrollController.position.maxScrollExtent) {
          print("showLoadMore");
          print(showLoadMore);
          if (showLoadMore) {
            setState(() {
              catPage = catPage + 1;
            });
            getCatSounds(catId);
          }
        }
      });
    });
  }

  /*SoundData find(List<SoundModel> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/

/*
  void scrollListener() {
    print(scrollController.position.extentAfter);
    if (scrollController.position.extentAfter == 0) {
      setState(() {
        loaderBGColor = Colors.black26;
        if (moreResults) {
          page++;
          getSoundResult = _getSounds();
        }
      });
    }
  }
*/

}
/*

class PlayerWidget extends StatefulWidget {
  final SoundData sound;
  final ValueSetter<SoundData> onItemTap;
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();

  const PlayerWidget({
    @required this.sound,
    @required this.onItemTap,
  });
}

class _PlayerWidgetState extends State<PlayerWidget> {
  int userId = 0;
  int videoId = 0;
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  AssetsAudioPlayer assetsAudioPlayer = new AssetsAudioPlayer();
  Future<dynamic> _setFavSounds(soundId, set) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    userId = pref.getInt('user_id');
    String appToken = pref.getString('app_token');

    Dio dio = new Dio();
    dio.options.baseUrl = Helper.getUri('').toString();
    setState(() {
      showLoader = true;
    });

    try {
      var response = await dio.post(
        "api/v1/set-fav-sound",
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'USER': Helper.getApiUser.toString(),
            'KEY': Helper.getApiKey().toString(),
          },
        ),
        queryParameters: {
          "login_id": userId,
          "app_token": appToken,
          "sound_id": soundId,
          "set": set,
        },
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          setState(() {
            showLoader = false;
          });
        }
        return response.data['msg'];
      } else {
        return "There's some server side issue";
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    assetsAudioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
      theme: NeumorphicThemeData(
        accentColor: Colors.black,
        variantColor: Colors.black,
        intensity: 0.8,
        lightSource: LightSource.topLeft,
        shadowLightColor: Colors.black54,
        shadowDarkColor: Colors.black54,
      ),
      child: StreamBuilder(
        stream: assetsAudioPlayer.isPlaying,
        initialData: false,
        builder: (context, snapshotPlaying) {
          final isPlaying = snapshotPlaying.data;
          return Neumorphic(
            margin: EdgeInsets.all(2),
            style: NeumorphicStyle(
              color: Colors.black,
              shadowLightColor: Colors.black54,
              shadowDarkColor: Colors.black54,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
//                        color: Colors.grey,
            ),
            padding: const EdgeInsets.all(8.0),
            child: NeumorphicTheme(
              darkTheme: NeumorphicThemeData(
                baseColor: Colors.black54,
                accentColor: Colors.black54,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                print("Gesture");
                                if (assetsAudioPlayer.current.value == null) {
                                  AssetsAudioPlayer.allPlayers()
                                      .forEach((key, value) {
                                    value.pause();
                                  });
                                  assetsAudioPlayer.open(
                                      Audio.network(widget.sound.url),
                                      autoStart: true);
                                } else {
                                  AssetsAudioPlayer.allPlayers()
                                      .forEach((key, value) {
                                    value.pause();
                                  });
                                  assetsAudioPlayer.playOrPause();
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(8.0),
                                child: Image.asset(
                                  isPlaying
                                      ? "assets/icons/pause-icon.png"
                                      : "assets/icons/play-icon.png",
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        this.widget.sound.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: MarqueeWidget(
                                              child: Text(
                                                this.widget.sound.album,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Text(
                                            "Duration: " +
                                                widget.sound.duration
                                                    .toString() +
                                                " sec",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Neumorphic(
                                  style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.circle(),
                                    depth: 8,
                                    surfaceIntensity: 1,
                                    shadowLightColor: Colors.black54,
                                    shadowDarkColor: Colors.black54,
                                    shape: NeumorphicShape.concave,
                                  ),
                                  child: NeumorphicRadio(
                                    style: NeumorphicRadioStyle(
                                      boxShape: NeumorphicBoxShape.circle(),
                                    ),
                                    value: LoopMode.playlist,
                                    child: Image.asset(
                                      widget.sound.fav > 0
                                          ? "assets/icons/like-icon-on.png"
                                          : "assets/icons/like-icon-off.png",
                                      width: 26,
                                      height: 26,
                                    ),
                                    onChanged: (newValue) async {
                                      String msg = await _setFavSounds(
                                          widget.sound.soundId,
                                          widget.sound.fav > 0
                                              ? "false"
                                              : "true");
                                      if (msg != null && msg.contains('set')) {
                                        setState(() {
                                          widget.sound.fav = 1;
                                        });
                                      } else {
                                        setState(() {
                                          widget.sound.fav = 0;
                                        });
                                      }
                                      Scaffold.of(context).showSnackBar(
                                        Helper.toast(
                                          msg,
                                          Colors.pinkAccent,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    assetsAudioPlayer.playOrPause();
                                    widget.onItemTap(this.widget.sound);
                                  },
                                  child: isPlaying
                                      ? Image.asset(
                                          "assets/icons/select-sound.png",
                                          height: 30,
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                            widget.sound.usedTimes > 0
                                ? Container(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Used " +
                                              widget.sound.usedTimes.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

//  }
//}
class SoundCatList extends StatefulWidget {
  final ValueSetter<SoundData> onItemTap;
  final int catId;
  SoundCatList(this.onItemTap, this.catId);
  @override
  _SoundCatListState createState() => _SoundCatListState();
}

class _SoundCatListState extends State<SoundCatList> {
  Map<String, dynamic> sounds = {};
  int currentIndex;
  ScrollController scrollCatController;
  String currentFile;
  var jsonData;
  var _getSoundResult;
  bool allPaused;
  var response;
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  List soundsList = [];
  var _textController = TextEditingController();

  static String searchKeyword = '';

  int page = 1;
  bool moreResults = true;
  Color loaderBGColor = Colors.black;

  Future _getCatSounds() async {
    print("_getSounds");
    Dio dio = new Dio();
    dio.options.baseUrl = Helper.getUri('').toString();
    setState(() {
      showLoader = true;
    });
    try {
      var response = await dio.get("get-cat-sounds",
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'USER': Helper.getApiUser.toString(),
              'KEY': Helper.getApiKey().toString(),
            },
          ),
          queryParameters: {
            "page": page,
            "page_size": 10,
            "search": searchKeyword,
            "cat_id": widget.catId
          });
      if (response.data['status'] == 'success') {
        jsonData = response.data;
        print("jsonData");
        print(jsonData);
        setState(() {
          showLoader = false;
        });
        var map = Map<String, dynamic>.from(response.data);
        print("map");
        print(map);
//        var res = SoundModelList.fromJson(map);
        print("response");
//        print(res);
        SoundModelList soundList = SoundModelList.fromJSON(map);
        print("soundList.data");
        print(soundList.data);
        setState(() {
          if (soundList.data.length > 0) {
            if (soundsList.length > 0) {
              print("second");
              soundsList.addAll(soundList.data);
            } else {
              print("first");
              soundsList = soundList.data;
            }
          } else {
            setState(() {
              moreResults = false;
            });
          }
        });
        return soundList;
      }
    } catch (e) {
      print(e);
    }
  }

  void _scrollCatListener() {
    print(scrollCatController.position.extentAfter);
    if (scrollCatController.position.extentAfter == 0) {
      setState(() {
        loaderBGColor = Colors.black26;
        if (moreResults) {
          page++;
          _getCatSounds();
        }
      });
    }
  }

  final AssetsAudioPlayer _assetsAudioPlayer =
      AssetsAudioPlayer.withId("4234234323asdsad");

  @override
  void initState() {
    _assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    });
    _assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    });
    _getSoundResult = _getCatSounds();
    scrollCatController = new ScrollController()..addListener(_scrollCatListener);
    super.initState();
  }


  */
/*SoundData find(List<SoundModel> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/ /*

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.grey[900],
        child: ModalProgressHUD(
          progressIndicator: showLoaderSpinner(),
          inAsyncCall: showLoader,
          opacity: 1.0,
          color: loaderBGColor,
          child: FutureBuilder(
            future: _getSoundResult,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // return: show loading widget
              }
              if (snapshot.hasError) {
                // return: show error widget
              }
              print(snapshot.data);
              // var soundList = snapshot.data ?? [];
              */
/*print("soundsList");
              print(soundsList);*/ /*

              return SafeArea(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 2,
                      child: Container(
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16.0,
                          ),
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            searchKeyword = val;
                            if (val.length > 2) {
                              Timer(Duration(seconds: 2), () {});
                            }
                          },
                          decoration: new InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 0.3),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 0.3),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white54, width: 0.3),
                            ),
                            hintText: "Search",
                            hintStyle: TextStyle(
                                fontSize: 16.0, color: Colors.white54),
                            //contentPadding:EdgeInsets.all(10),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.only(bottom: 12),
                              onPressed: () {
                                _textController.clear();
                                _getSoundResult = _getCatSounds();
                              },
                              icon: Icon(
                                Icons.clear,
                                color: searchKeyword != ""
                                    ? Colors.white54
                                    : Colors.transparent,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Container(
                          color: Colors.black,
                          height: MediaQuery.of(context).size.height - 150,
                          child: ListView.builder(
                            controller: scrollCatController,
                            itemCount: soundsList.length,
                            itemBuilder: (context, index) {
                              return PlayerWidget(
                                sound: soundsList[index],
                                onItemTap: (e) {
                                  widget.onItemTap(soundsList[index]);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
*/
