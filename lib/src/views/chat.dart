import 'package:Leuke/src/views/user_profile_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../controllers/chat_controller.dart';
import '../helpers/helper.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/user_repository.dart';
import 'my_profile_view.dart';

class ChatView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int userId;
  final String userName;
  ChatView({Key key, this.userId, this.userName, this.parentScaffoldKey}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends StateMVC<ChatView> {
  ChatController _con;
  _ChatViewState() : super(ChatController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.userId = widget.userId;
    _con.chatListing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    _con.loadMoreUpdateView.addListener(() {
      if (_con.loadMoreUpdateView.value) {
        setState(() {});
      }
    });

    AppBar appBar = AppBar(
      iconTheme: IconThemeData(
        color: settingRepo.setting.value.iconColor, //change your color here
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
        onPressed: () => Navigator.pushReplacementNamed(
          context,
          "/user-chats",
        ),
      ),
      backgroundColor: settingRepo.setting.value.bgColor.withOpacity(0.8),
      // elevation: 100,
      centerTitle: true,
      automaticallyImplyLeading: true,
      title: InkWell(
        onTap: () {
          print("|aaac");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.userId == userRepo.currentUser.value.userId
                  ? MyProfileView()
                  : UsersProfileView(
                      userId: widget.userId,
                    ),
            ),
          );
        },
        child: Text(
          widget.userName,
          style: TextStyle(
            color: settingRepo.setting.value.headingColor,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    @override
    void dispose() {
      // TODO: implement dispose
      super.dispose();
    }

    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(
          context,
          "/user-chats",
        );
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          key: _con.scaffoldKey,
          backgroundColor: settingRepo.setting.value.bgColor,
          appBar: appBar,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: ValueListenableBuilder(
                    valueListenable: chatData,
                    builder: (context, ChatModel _chat, _) {
                      return ValueListenableBuilder(
                          valueListenable: _con.showLoader,
                          builder: (context, loader, _) {
                            // _chat.chat = _chat.chat.reversed.toList();
                            return ModalProgressHUD(
                              inAsyncCall: loader,
                              progressIndicator: Helper.showLoaderSpinner(Colors.black),
                              child: Container(
                                color: settingRepo.setting.value.bgColor,
                                // height: MediaQuery.of(context).size.height -
                                //     (appBar.preferredSize.height + 80),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _chat.chat.length > 0
                                        ? Expanded(
                                            child: GroupedListView<Chat, String>(
                                              elements: _chat.chat,
                                              controller: _con.scrollController,
                                              groupBy: (Chat element) => element.sentDate,
                                              groupSeparatorBuilder: (String groupByValue) => Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Divider(
                                                        color: settingRepo.setting.value.dividerColor.withOpacity(0.3),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 1.7),
                                                        child: Container(
                                                          padding: EdgeInsets.all(
                                                            6.0,
                                                          ),
                                                          margin: EdgeInsets.all(
                                                            3,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(15),
                                                            ),
                                                            color: settingRepo.setting.value.buttonColor,
                                                          ),
                                                          child: Text(
                                                            groupByValue,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                              color: settingRepo.setting.value.buttonTextColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Divider(
                                                      color: settingRepo.setting.value.dividerColor.withOpacity(0.3),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              itemBuilder: (context, Chat item) {
                                                return Container(
                                                  width: width,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: (item.fromId == currentUser.value.userId) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Wrap(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: (item.fromId != currentUser.value.userId) ? EdgeInsets.only(right: 100.0) : EdgeInsets.only(left: 100.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: (item.fromId != currentUser.value.userId) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                                              children: <Widget>[
                                                                Container(
                                                                  padding: EdgeInsets.all(10.0),
                                                                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    color: (item.fromId != currentUser.value.userId) ? settingRepo.setting.value.senderMsgColor : settingRepo.setting.value.myMsgColor,
                                                                  ),
                                                                  child: Text(
                                                                    item.msg,
                                                                    style: TextStyle(
                                                                      color: (item.fromId != currentUser.value.userId)
                                                                          ? settingRepo.setting.value.senderMsgTextColor
                                                                          : settingRepo.setting.value.myMsgTextColor,
                                                                      fontSize: 15.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                    top: 5.0,
                                                                    bottom: 10,
                                                                    right: 12,
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment: (item.fromId != currentUser.value.userId) ? MainAxisAlignment.start : MainAxisAlignment.end,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      (item.fromId != currentUser.value.userId)
                                                                          ? Container()
                                                                          : Icon(
                                                                              (item.isRead) ? Icons.done_all : Icons.check,
                                                                              color: Colors.blueAccent,
                                                                              size: 14.0,
                                                                            ),
                                                                      SizedBox(
                                                                        width: 7.0,
                                                                      ),
                                                                      Text(
                                                                        item.sentOn,
                                                                        style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 10.0,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              /* itemComparator: (item1, item2) =>
                                                  DateFormat("yyyy-MM-dd HH:mm:ss").parse(item1.sentDatetime).isBefore(DateFormat("yyyy-MM-dd HH:mm:ss").parse(item2.sentDatetime)) ? 0 : 1, // optional*/
                                              itemComparator: (item1, item2) => (DateFormat("yyyy-MM-dd HH:mm:ss").parse(item1.sentDatetime))
                                                  .millisecondsSinceEpoch
                                                  .compareTo((DateFormat("yyyy-MM-dd HH:mm:ss").parse(item2.sentDatetime)).millisecondsSinceEpoch), // optional
                                              useStickyGroupSeparators: true, // optional
                                              floatingHeader: true, // optional
                                              order: GroupedListOrder.DESC,
                                              reverse: true,
                                            ),
                                          )
                                        : (_con.showLoad)
                                            ? Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SkeletonLoader(
                                                  builder: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: MediaQuery.of(context).size.width / 2,
                                                              height: 30,
                                                              decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(3)),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              width: 150,
                                                              height: 30,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            height: 15,
                                                            decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(3)),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: 150,
                                                              height: 30,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              width: MediaQuery.of(context).size.width / 2,
                                                              height: 30,
                                                              decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(3)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            height: 15,
                                                            decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(3)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  items: _chat.totalChat == 0 ? 5 : _chat.totalChat,
                                                  period: Duration(seconds: 1),
                                                  highlightColor: Colors.white60,
                                                  direction: SkeletonDirection.ltr,
                                                ),
                                              )
                                            : Container(
                                                // height: config.App(context)
                                                //     .appHeight(80),
                                                width: MediaQuery.of(context).size.width,
                                              ),
                                  ],
                                ),
                              ),
                            );
                          });
                    }),
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _con.showTyping,
                      builder: (context, typing, _) {
                        return typing
                            ? Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Image.asset(
                                  'assets/icons/typing.gif',
                                  width: 40,
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              );
                      },
                    ),
                    Container(
                      width: width,
                      height: 70.0,
                      // padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                // borderRadius: BorderRadius.circular(10.0),
                                // color: Colors.grey.withOpacity(0.2),
                                color: settingRepo.setting.value.accentColor,
                              ),
                              child: TextField(
                                controller: _con.msgController,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: settingRepo.setting.value.textColor,
                                ),
                                onTap: () {
                                  //_con.scrollToBottom();
                                },
                                onChanged: (value) {
                                  _con.typing();
                                  _con.msg = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Send Your Message',
                                  hintStyle: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey,
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    left: 10.0,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(width: 10.0),
                          Expanded(
                            child: SizedBox(
                              height: 48.0,
                              child: RaisedButton(
                                padding: EdgeInsets.all(0.0),
                                shape: RoundedRectangleBorder(
                                    // borderRadius: BorderRadius.circular(20.0),
                                    ),
                                color: settingRepo.setting.value.buttonColor,
                                child: Icon(
                                  Icons.send,
                                  color: settingRepo.setting.value.iconColor,
                                  size: 30.0,
                                ),
                                onPressed: () {
                                  if (_con.msgController.text != '') {
                                    if (_con.now.hour > 11) {
                                      _con.amPm = 'PM';
                                    } else {
                                      _con.amPm = 'AM';
                                    }
                                    setState(() {
                                      _con.sendMsg();
                                      _con.scrollController != null ??
                                          _con.scrollController.animateTo(
                                            _con.scrollController.position.maxScrollExtent,
                                            curve: Curves.easeOut,
                                            duration: const Duration(milliseconds: 300),
                                          );
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
