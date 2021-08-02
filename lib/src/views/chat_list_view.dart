import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../controllers/chat_list_controller.dart';
import '../helpers/helper.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/friendslist_view.dart';
import 'chat.dart';

class ChatListView extends StatefulWidget {
  @override
  _ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends StateMVC<ChatListView> {
  ChatListController _con;
  _ChatListViewState() : super(ChatListController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
    _con.chatHistoryListing(1);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _con.loadMoreUpdateView.addListener(() {
      if (_con.loadMoreUpdateView.value) {
        setState(() {});
      }
    });
    return WillPopScope(
      onWillPop: () async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: settingRepo.setting.value.bgColor,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendsListView(),
                ),
              );
            },
            child: Icon(
              Icons.message,
              color: settingRepo.setting.value.iconColor,
              size: 30,
            ),
            backgroundColor: settingRepo.setting.value.buttonColor,
            tooltip: 'New Message',
            elevation: 5,
            splashColor: Colors.grey,
          ),
          // backgroundColor: Colors.black,
          body: ValueListenableBuilder(
              valueListenable: chatRepo.chatHistoryData,
              builder: (context, ChatModel _chat, _) {
                print("print_chat");
                print(_chat.chat);
                return ValueListenableBuilder(
                    valueListenable: _con.showLoader,
                    builder: (context, loader, _) {
                      return ModalProgressHUD(
                        inAsyncCall: loader,
                        progressIndicator: Helper.showLoaderSpinner(
                          settingRepo.setting.value.accentColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                              child: Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      videoRepo.homeCon.value.showFollowingPage.value = false;
                                      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                      videoRepo.homeCon.value.getVideos();
                                      Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: settingRepo.setting.value.iconColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Messages",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: settingRepo.setting.value.headingColor,
                                      ),
                                    ),
                                  )
                                  /*InkWell(
                                    onTap: () {},
                                    child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Icon(Icons.search)),
                                  )*/
                                ],
                              ),
                            ),
                            _chat.chat.length > 0
                                ? Expanded(
                                    child: AnimatedList(
                                      shrinkWrap: true,
                                      controller: _con.scrollController,
                                      initialItemCount: _chat.chat.length,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, index, animation) {
                                        print("Chat index $index");
                                        print(json.encode(_chat.chat[index]));
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(-1, 0),
                                            end: Offset(0, 0),
                                          ).animate(animation),
                                          child: ChatItem(
                                            chat: _chat.chat[index],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : (_con.showLoad)
                                    ? SkeletonLoader(
                                        builder: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 18,
                                              ),
                                              SizedBox(width: 20),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Container(
                                                        height: 8,
                                                        width: 80,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 8,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 0,
                                                child: Column(
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Container(
                                                        height: 8,
                                                        width: 40,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    SizedBox(height: 8),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        items: 10,
                                        period: Duration(seconds: 1),
                                        highlightColor: Colors.white60,
                                        direction: SkeletonDirection.ltr,
                                      )
                                    : Center(
                                        child: Container(
                                          height: MediaQuery.of(context).size.height - 200,
                                          width: MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "No chat history!",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.textColor.withOpacity(0.7),
                                                  fontSize: 17,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                            /*Padding(
                              padding: EdgeInsets.only(top: 40.0, bottom: 10),
                              child: Center(
                                child: Text(
                                  'no more messages',
                                  style: TextStyle(color: Colors.grey[350]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      );
                    });
              }),
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final Chat chat;

  ChatItem({this.chat});

  Widget _activeIcon(isActive) {
    if (isActive) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3),
          width: 16,
          height: 16,
          color: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: Color(0xff43ce7d), // flat green
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Chat Item Read" + {this.chat.isRead}.toString());
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatView(
              userId: chat.toId,
              userName: chat.username,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 12.0),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      print('You want to see the display pictute.');
                    },
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(this.chat.userDp),
                      radius: 30.0,
                    ),
                  ),
                  /*Positioned(
                    right: 0,
                    bottom: 0,
                    child: _activeIcon(this.chat.),
                  ),*/
                ],
              ),
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 6.0, right: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.chat.username,
                        style: TextStyle(fontSize: 18, color: settingRepo.setting.value.headingColor),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0),
                        child: Text(
                          this.chat.msg,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  )),
            ),
            Column(
              children: <Widget>[
                Text(
                  // TimeAgo.timeAgoSinceDate(this.chat.sentOn),
                  this.chat.sentOn,
                  style: TextStyle(
                    color: Colors.grey[350],
                  ),
                ),
                _UnreadIndicator(this.chat.isRead),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  final bool read;

  _UnreadIndicator(this.read);

  @override
  Widget build(BuildContext context) {
    print("isread $read");
    if (read == true) {
      return Container(); // return empty container
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 15,
                color: Color(0xff3e5aeb),
                width: 15,
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                child: Text(
                  "",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )));
    }
  }
}
