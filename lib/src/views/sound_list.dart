import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/sound_list_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/sound_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/sound_repository.dart' as soundRepo;
import '../widgets/MarqueWidget.dart';

class SoundList extends StatefulWidget {
  SoundList();
  @override
  _SoundListState createState() => _SoundListState();
}

class _SoundListState extends StateMVC<SoundList> {
  SoundListController _con;
  _SoundListState() : super(SoundListController()) {
    _con = controller;
  }
  @override
  void initState() {
    _con.assetsAudioPlayer.playlistFinished.listen((data) {
      print("finished : $data");
    });
    _con.assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _con.assetsAudioPlayer.current.listen((data) {
      print("current : $data");
    });
    _con.getSounds();
/*
    _con.scrollController = new ScrollController()
      ..addListener(_scrollListener);*/
    super.initState();
  }

  @override
  void dispose() {
    _con.assetsAudioPlayer.dispose();
    super.dispose();
  }

  /*SoundModel find(List<SoundData> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: settingRepo.setting.value.bgColor,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: settingRepo.setting.value.iconColor,
              ),
              onPressed: () async {
                Navigator.pushReplacementNamed(context, '/video-recorder');
              }),
          title: null,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          /*actions: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: GestureDetector(
                onTap: () {
                  */ /* Navigator.push(
                    context,
                    PageTransition(
                      duration: Duration(milliseconds: 800),
                      reverseDuration: Duration(milliseconds: 800),
                      type: PageTransitionType.rightToLeftWithFade,
                      alignment: Alignment.topCenter,
                      child: RecordingView(),
                    ),
                  );*/ /*
                },
                child: Text(
                  "다음",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          ],*/
        ),
        body: Material(
          child: Container(
            color: settingRepo.setting.value.bgColor,
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: TabBar(
                      onTap: (index) {
                        if (index == 1) {
                          _con.getFavSounds();
                        } else {
                          _con.getSounds();
                        }
                      },
                      indicatorColor: settingRepo.setting.value.dividerColor,
                      labelColor: settingRepo.setting.value.headingColor,
                      unselectedLabelColor: Colors.grey[400],
                      indicatorWeight: 0.3,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Music",
                              style: TextStyle(
//                        color: Color(0xff06638f),
                                fontSize: 22,
                                fontFamily: 'RockWellStd',
                                color: settingRepo.setting.value.subHeadingColor,
                              ),
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Favorites",
                                  style: TextStyle(
//                        color: Color(0xff06638f),
                                    fontSize: 22,
                                    fontFamily: 'RockWellStd',
                                    color: settingRepo.setting.value.subHeadingColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Icon(
                                  Icons.favorite,
                                  size: 20,
                                  color: settingRepo.setting.value.iconColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: settingRepo.setting.value.bgColor,
                    height: MediaQuery.of(context).size.height - 150,
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 2,
                              child: Container(
                                color: settingRepo.setting.value.bgColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 50,
                                child: TextField(
                                  controller: _con.textController1,
                                  style: TextStyle(
                                    color: settingRepo.setting.value.textColor,
                                    fontSize: 16.0,
                                  ),
                                  obscureText: false,
                                  keyboardType: TextInputType.text,
                                  onChanged: (String val) {
                                    // _con.searchKeyword1 = val;
                                    if (val.length > 2) {
                                      Timer(Duration(milliseconds: 1000), () {
                                        _con.getSounds(val);
                                      });
                                    }
                                    if (val.length == 0) {
                                      print("length 0");
                                      Timer(Duration(milliseconds: 1000), () {
                                        _con.getSounds();
                                      });
                                    }
                                  },
                                  decoration: new InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: settingRepo.setting.value.dividerColor,
                                        width: 0.3,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: settingRepo.setting.value.dividerColor,
                                        width: 0.3,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                    ),
                                    hintText: "Search sounds",
                                    hintStyle: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                    ),
                                    //contentPadding:EdgeInsets.all(10),

                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.only(bottom: 12),
                                      onPressed: () {
                                        _con.textController1.clear();
                                        _con.searchKeyword = "";
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: _con.searchKeyword != "" ? settingRepo.setting.value.iconColor : Colors.transparent,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: soundRepo.soundsData,
                                builder: (context, SoundModelList _sounds, _) {
                                  if ((_sounds.data != null)) {
                                    if (_sounds.data.length > 0) {
                                      return Column(
                                        children: <Widget>[
                                          SingleChildScrollView(
                                            child: SizedBox(
                                              height: MediaQuery.of(context).size.height - 200,
                                              child: ModalProgressHUD(
                                                progressIndicator: _con.showLoaderSpinner(),
                                                inAsyncCall: _con.showLoader,
                                                opacity: 1.0,
                                                color: settingRepo.setting.value.bgColor.withOpacity(0.5),
                                                child: GroupedListView<SoundData, String>(
                                                  controller: _con.scrollController,
                                                  elements: _sounds.data,
                                                  groupBy: (element) => element.category + "_" + element.catId,
                                                  order: GroupedListOrder.DESC,
//                                        useStickyGroupSeparators: true,
                                                  groupSeparatorBuilder: (String value) {
                                                    print("catVlaue");
                                                    print(value);
                                                    var full = value.split("_");
                                                    return Container(
                                                      color: settingRepo.setting.value.bgColor,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                              full[0],
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontSize: 22,
                                                                color: settingRepo.setting.value.textColor,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => SoundCatList(int.parse(full[1]), full[0]),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(7),
                                                                  color: settingRepo.setting.value.bgColor.withOpacity(0.5),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(4.0),
                                                                  child: Text(
                                                                    "View More",
                                                                    style: TextStyle(
                                                                      fontSize: 10,
                                                                      color: settingRepo.setting.value.textColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  itemBuilder: (c, e) {
                                                    return PlayerWidget(
                                                      sound: e,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      if (!_con.showLoader) {
                                        return Center(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height - 185,
                                            width: MediaQuery.of(context).size.width,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "No Sounds found",
                                                  style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          color: settingRepo.setting.value.bgColor,
                                          child: Center(
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: new AlwaysStoppedAnimation<Color>(settingRepo.setting.value.iconColor),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    if (!_con.showLoader) {
                                      return Center(
                                        child: Container(
                                          height: MediaQuery.of(context).size.height - 185,
                                          width: MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "No Sounds found",
                                                style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 15),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        color: settingRepo.setting.value.bgColor,
                                        child: Center(
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: new AlwaysStoppedAnimation<Color>(
                                                settingRepo.setting.value.iconColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  // : Helper.showLoaderSpinner(Colors.white);
                                }),
                          ],
                        ),
                        ModalProgressHUD(
                          progressIndicator: _con.showLoaderSpinner(),
                          inAsyncCall: _con.showLoader,
                          opacity: 1.0,
                          color: settingRepo.setting.value.bgColor,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 2,
                                child: Container(
                                  color: settingRepo.setting.value.bgColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 50,
                                  child: TextField(
                                    controller: _con.textController2,
                                    style: TextStyle(
                                      color: settingRepo.setting.value.textColor,
                                      fontSize: 16.0,
                                    ),
                                    obscureText: false,
                                    keyboardType: TextInputType.text,
                                    onChanged: (String val) {
                                      _con.searchKeyword2 = val;
                                      if (val.length > 2) {
                                        Timer(Duration(seconds: 1), () {
                                          _con.getFavSounds(val);
                                        });
                                      }
                                      if (val.length == 0) {
                                        Timer(Duration(milliseconds: 1000), () {
                                          _con.getFavSounds();
                                        });
                                      }
                                    },
                                    decoration: new InputDecoration(
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                                      ),
                                      hintText: "Search Favorite sound",
                                      hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
                                      //contentPadding:EdgeInsets.all(10),
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.only(bottom: 12),
                                        onPressed: () {
                                          _con.textController2.clear();
                                          setState(() {
                                            _con.searchKeyword2 = "";
                                          });
                                          _con.getFavSounds();
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: _con.searchKeyword2 != "" ? settingRepo.setting.value.iconColor : Colors.transparent,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 48.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * .8 - 90,
                                    child: ValueListenableBuilder(
                                        valueListenable: soundRepo.favSoundsData,
                                        builder: (context, SoundModelList _favSounds, _) {
                                          return (_favSounds.data != null && _favSounds.data.length > 0)
                                              ? ListView.builder(
                                                  controller: _con.scrollController1,
                                                  itemCount: _favSounds.data.length,
                                                  itemBuilder: (context, index) {
                                                    print("albumName");
                                                    print(_favSounds.data[index].album);
                                                    return PlayerWidget(
                                                      sound: _favSounds.data[index],
                                                    );
                                                  })
                                              : (!_con.showLoader)
                                                  ? Center(
                                                      child: Container(
                                                        height: MediaQuery.of(context).size.height - 360,
                                                        width: MediaQuery.of(context).size.width,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Text(
                                                              "No favourite sounds found",
                                                              style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 15),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      color: settingRepo.setting.value.bgColor,
                                                      child: Center(
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: new AlwaysStoppedAnimation<Color>(settingRepo.setting.value.iconColor),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final SoundData sound;
  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();

  const PlayerWidget({
    @required this.sound,
  });
}

class _PlayerWidgetState extends StateMVC<PlayerWidget> {
  int userId = 0;
  int videoId = 0;
  bool showLoader = true;
  AssetsAudioPlayer assetsAudioPlayer = new AssetsAudioPlayer();
  SoundListController _con;
  int isFav = 0;
  bool showLoading = false;
  _PlayerWidgetState() : super(SoundListController()) {
    _con = controller;
  }

  @override
  void initState() {
    setState(() {
      isFav = widget.sound.fav;
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    assetsAudioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: assetsAudioPlayer.isPlaying,
      initialData: false,
      builder: (context, snapshotPlaying) {
        final isPlaying = snapshotPlaying.data;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: Gradients.blush,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Container(
                padding: EdgeInsets.all(4),
                width: config.App(context).appWidth(100),
                decoration: BoxDecoration(
                  color: settingRepo.setting.value.bgColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              if (assetsAudioPlayer.current.first == null) {
                                AssetsAudioPlayer.allPlayers().forEach((key, value) {
                                  value.pause();
                                });
                                setState(() {
                                  showLoading = true;
                                });
                                await DefaultCacheManager().getSingleFile(widget.sound.url).then((file) {
                                  AssetsAudioPlayer.allPlayers().forEach((key, value) {
                                    value.pause();
                                  });
                                  assetsAudioPlayer.open(
                                    Audio.file(file.path),
                                    autoStart: true,
                                  );
                                  setState(() {
                                    showLoading = false;
                                  });
                                  print("isBuffering");
                                  print(assetsAudioPlayer.isBuffering);
                                });
                              } else {
                                AssetsAudioPlayer.allPlayers().forEach((key, value) {
                                  value.pause();
                                });
                                assetsAudioPlayer.playOrPause();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  image: new DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      widget.sound.imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  // gradient: Gradients.blush,
                                ),
                                child: Center(
                                  child: showLoading
                                      ? Container(width: 40, height: 40, child: Helper.showLoaderSpinner(Colors.white))
                                      : IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline,
                                            size: 40,
                                            color: settingRepo.setting.value.iconColor,
                                          ),
                                          onPressed: () async {
                                            AssetsAudioPlayer.allPlayers().forEach((key, value) {
                                              value.pause();
                                            });
                                            if (!isPlaying) {
                                              final List<StreamSubscription> _subscriptions = [];
                                              _subscriptions.add(assetsAudioPlayer.isBuffering.listen((isBuffering) {
                                                if (isBuffering) {
                                                  setState(() {
                                                    showLoading = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    showLoading = false;
                                                  });
                                                }
                                              }));
                                              assetsAudioPlayer.open(
                                                Audio.network(widget.sound.url),
                                                autoStart: true,
                                              );
                                            } else {
                                              assetsAudioPlayer.pause();
                                            }
                                          },
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: InkWell(
                                onTap: () async {
                                  print("Audio Url");
                                  print(widget.sound.url);
                                  AssetsAudioPlayer.allPlayers().forEach((key, value) {
                                    value.pause();
                                  });
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          insetPadding: EdgeInsets.zero,
                                          content: Container(
                                            height: 50,
                                            child: Row(
                                              children: [
                                                Helper.showLoaderSpinner(Colors.black),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "Downloading.. Please wait...",
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                  print("this.widget.sound");
                                  print(this.widget.sound.url);
                                  _con.selectSound(this.widget.sound);
                                  DefaultCacheManager().getSingleFile(widget.sound.url).then((file) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/video-recorder',
                                    );
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        width: config.App(context).appWidth(100),
                                        child: MarqueeWidget(
                                          child: Text(
                                            this.widget.sound.title,
                                            style: TextStyle(
                                              color: settingRepo.setting.value.textColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 100,
                                          child: MarqueeWidget(
                                            child: Text(
                                              widget.sound.album,
                                              style: TextStyle(
                                                color: settingRepo.setting.value.textColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          //width: config.App(context).appWidth(40),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.sound.duration.toString() + " sec",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.textColor,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              widget.sound.usedTimes > 0
                                                  ? Container(
                                                      child: Align(
                                                        alignment: Alignment.bottomCenter,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            "Used " + widget.sound.usedTimes.toString(),
                                                            style: TextStyle(
                                                              color: settingRepo.setting.value.textColor,
                                                              fontSize: 11,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: Gradients.blush),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFav > 0 ? Icons.favorite : Icons.favorite_border,
                              size: 25,
                              color: settingRepo.setting.value.iconColor,
                            ),
                            onPressed: () async {
                              setState(() {
                                isFav = isFav == 1 ? 0 : 1;
                              });
                              String msg = await _con.setFavSounds(widget.sound.soundId, widget.sound.fav > 0 ? "false" : "true");
                              if (msg != null && msg.contains('set')) {
                                setState(() {
                                  isFav = 1;
                                  widget.sound.fav = 1;
                                });
                              } else {
                                setState(() {
                                  isFav = 0;
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
                      ),
                      // child: Column(
                      //   children: <Widget>[
                      //     Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       mainAxisSize: MainAxisSize.max,
                      //       children: [
                      //         Neumorphic(
                      //           style: NeumorphicStyle(
                      //             boxShape: NeumorphicBoxShape.circle(),
                      //             depth: 8,
                      //             surfaceIntensity: 1,
                      //             shadowLightColor: Theme.of(context)
                      //                 .primaryColor
                      //                 .withOpacity(0.5),
                      //             shadowDarkColor: Theme.of(context)
                      //                 .primaryColor
                      //                 .withOpacity(0.5),
                      //             shape: NeumorphicShape.concave,
                      //           ),
                      //           child: NeumorphicRadio(
                      //             style: NeumorphicRadioStyle(
                      //               boxShape: NeumorphicBoxShape.circle(),
                      //             ),
                      //             value: LoopMode.playlist,
                      //             child: Image.asset(
                      //               widget.sound.fav > 0
                      //                   ? "assets/icons/like-icon-on.png"
                      //                   : "assets/icons/like-icon-off.png",
                      //               width: 26,
                      //               height: 26,
                      //             ),
                      //             onChanged: (newValue) async {
                      //               String msg = await _con.setFavSounds(
                      //                   widget.sound.soundId,
                      //                   widget.sound.fav > 0
                      //                       ? "false"
                      //                       : "true");
                      //               if (msg != null && msg.contains('set')) {
                      //                 setState(() {
                      //                   widget.sound.fav = 1;
                      //                 });
                      //               } else {
                      //                 setState(() {
                      //                   widget.sound.fav = 0;
                      //                 });
                      //               }
                      //               Scaffold.of(context).showSnackBar(
                      //                 Helper.toast(
                      //                   msg,
                      //                   Colors.pinkAccent,
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           width: 12,
                      //         ),
                      //         GestureDetector(
                      //           onTap: () {
                      //             assetsAudioPlayer.playOrPause();
                      //             _con.selectSound(this.widget.sound);
                      //             Navigator.pushNamed(context, '/recording');
                      //           },
                      //           child: isPlaying
                      //               ? Image.asset(
                      //                   "assets/icons/select-sound.png",
                      //                   height: 30,
                      //                 )
                      //               : Container(),
                      //         ),
                      //       ],
                      //     ),
                      //     widget.sound.usedTimes > 0
                      //         ? Container(
                      //             child: Align(
                      //               alignment: Alignment.bottomCenter,
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Text(
                      //                   "Used " +
                      //                       widget.sound.usedTimes.toString(),
                      //                   style: TextStyle(
                      //                     color:
                      //                         Colors.white,
                      //                     fontSize: 10,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           )
                      //         : Container(),
                      //   ],
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//  }
//}
class SoundCatList extends StatefulWidget {
  final int catId;
  final String catName;
  SoundCatList(this.catId, this.catName);
  @override
  _SoundCatListState createState() => _SoundCatListState();
}

class _SoundCatListState extends StateMVC<SoundCatList> {
  Map<String, dynamic> sounds = {};

  List soundsList = [];
  var _textController = TextEditingController();
  SoundListController _con;
  _SoundCatListState() : super(SoundListController()) {
    _con = controller;
  }
  static String searchKeyword = '';

  int page = 1;
  bool moreResults = true;

  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("4234234323asdsad");

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

    print("widget.catId");
    print(widget.catId);
    _con.getCatSounds(widget.catId);
    super.initState();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    super.dispose();
  }

  /*SoundModel find(List<SoundData> source, String fromPath) {
    return source.firstWhere((element) => element.audio.path == fromPath);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      key: _con.soundScaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: settingRepo.setting.value.iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.catName,
          style: TextStyle(color: settingRepo.setting.value.textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.grey[900],
        child: ModalProgressHUD(
          progressIndicator: _con.showLoaderSpinner(),
          inAsyncCall: _con.showLoader,
          opacity: 0.5,
          color: settingRepo.setting.value.bgColor,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 2,
                  child: Container(
                    color: settingRepo.setting.value.bgColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 50,
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        color: settingRepo.setting.value.textColor,
                        fontSize: 16.0,
                      ),
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      onChanged: (String val) {
                        _con.catSearchKeyword = val;
                        if (val.length > 2) {
                          Timer(Duration(seconds: 1), () {
                            _con.getCatSounds(widget.catId, val);
                          });
                        }
                        if (val.length == 0) {
                          Timer(Duration(milliseconds: 1000), () {
                            _con.getCatSounds(widget.catId);
                          });
                        }
                      },
                      decoration: new InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: settingRepo.setting.value.dividerColor, width: 0.3),
                        ),
                        hintText: "Search",
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                        //contentPadding:EdgeInsets.all(10),
                        suffixIcon: IconButton(
                          padding: EdgeInsets.only(bottom: 12),
                          onPressed: () {
                            _textController.clear();
                            _con.getCatSounds(widget.catId);
                          },
                          icon: Icon(
                            Icons.clear,
                            color: searchKeyword != "" ? settingRepo.setting.value.iconColor : Colors.transparent,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: soundRepo.catSoundsData,
                  builder: (context, SoundModelList _catSounds, _) {
                    return (_catSounds.data != null && _catSounds.data.length > 0)
                        ? SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Container(
                                color: settingRepo.setting.value.bgColor,
                                height: MediaQuery.of(context).size.height - 150,
                                child: ListView.builder(
                                  controller: _con.catScrollController,
                                  itemCount: _catSounds.data.length,
                                  itemBuilder: (context, index) {
                                    return PlayerWidget(
                                      sound: _catSounds.data[index],
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        : (!_con.showLoader)
                            ? Center(
                                child: Container(
                                  height: MediaQuery.of(context).size.height - 360,
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "No favourite sounds found",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                color: settingRepo.setting.value.bgColor,
                                child: Center(
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
