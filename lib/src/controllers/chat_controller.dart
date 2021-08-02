import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/chat_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/socket_repository.dart' as socketRepo;
import '../repositories/user_repository.dart';

class ChatController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  final msgController = TextEditingController();
  DateTime now = DateTime.now();
  ScrollController scrollController = new ScrollController();
  ValueNotifier<bool> loadMoreUpdateView = new ValueNotifier(false);
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  ValueNotifier<bool> showTyping = new ValueNotifier(false);
  String amPm;
  bool showChatLoader = true;
  IO.Socket socket;
  int page = 1;
  int userId;
  bool showLoad;
  String msg = "";
  ChatController() {
    scrollController = new ScrollController();
  }

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    scrollToBottom();
    connectUser();
    super.initState();
  }

  @override
  void dispose() {
    socketRepo.clientSocket.value.on("disconnect", (_) => print('User disconnected'));
    super.dispose();
  }

  typing() async {
    socketRepo.clientSocket.value.emit("typing", {'from_id': currentUser.value.userId, 'to_id': userId});
  }

  connectUser() async {
    try {
      socketRepo.clientSocket.value.on('typing', (data) {
        data = jsonDecode(jsonEncode(data));
        print(data['from_id'].toString() + "++" + userId.toString());
        if (data['from_id'] == userId) {
          showTyping.value = true;
          showTyping.notifyListeners();
          Timer(Duration(seconds: 1), () {
            showTyping.value = false;
            showTyping.notifyListeners();
          });
        }
      });
      socketRepo.clientSocket.value.on('send_msg', (data) {
        if (data['from_id'] == userId) {
          appendMsg(data);
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  appendMsg([data]) async {
    print("appendData");
    DateTime timeNow = DateTime.now();
    var formatterDate = new DateFormat('dd MMM yyyy');
    var formatterDateTime = new DateFormat('yyyy-MM-dd HH:mm:ss');
    Chat chatObj = new Chat();
    if (data != null) {
      print("sentMsgData");
      print(data);
      data = jsonDecode(jsonEncode(data));
      print(data);
      chatObj.chatId = 0;
      chatObj.fromId = data['from_id'];
      chatObj.toId = data['to_id'];
      chatObj.msg = data['msg'];
      chatObj.isRead = false;
      chatObj.sentOn = data['sent_on'];
      chatObj.sentDate = formatterDate.format(timeNow);
      chatObj.sentDatetime = formatterDateTime.format(DateFormat("yyyy-MM-dd HH:mm:ss").parse(data["sent_on"]));
      if (data['msg'] != null && data['msg'].trim != "") {
        chatRepo.chatData.value.chat.insert(0, chatObj);
        // chatRepo.chatData.value.chat.add(chatObj);
      }
      chatRepo.chatData.notifyListeners();
    } else {
      print("asdsadasd");
      chatObj.chatId = 0;
      chatObj.fromId = currentUser.value.userId;
      chatObj.toId = userId;
      chatObj.msg = msg;
      chatObj.isRead = false;
      chatObj.sentDate = formatterDate.format(timeNow);
      chatObj.sentDatetime = formatterDateTime.format(timeNow);
      chatObj.sentOn = (timeNow.hour > 12)
          ? '${(timeNow.hour - 12).toString().length == 1 ? "0" + (timeNow.hour - 12).toString() : timeNow.hour}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute} ${amPm}'
          : '${timeNow.hour}:${timeNow.minute} ${amPm}';
      if (msg != null && msg.trim() != "") {
        chatRepo.chatData.value.chat.insert(0, chatObj);
        // chatRepo.chatData.value.chat.add(chatObj);
      }
      chatRepo.chatData.notifyListeners();
    }
    msgController.text = '';
    await Future.delayed(
      Duration(
        milliseconds: 800,
      ),
    );
    scrollToBottom();
  }

  void scrollToBottom() {
    print("scrollToBottom");
    if (scrollController.hasClients) {
      print("acxcxz");
      scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.elasticOut,
      );
    } else {
      print("asfdsfsdfg");
      Timer(
        Duration(
          milliseconds: 400,
        ),
        () => scrollToBottom(),
      );
    }
  }

  Future<void> chatListing() async {
    scrollController = new ScrollController();
    if (page > 1) {
      showLoader.value = true;
      showLoader.notifyListeners();
    } else {
      showLoad = true;
    }
    chatRepo.chatListing(page, userId).then((obj) {
      if (page > 1) {
        showLoader.value = false;
        showLoader.notifyListeners();
        loadMoreUpdateView.value = true;
        loadMoreUpdateView.notifyListeners();
      } else {
        showLoad = false;
      }
      if (obj.totalChat == obj.chat.length) {
        showChatLoader = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (obj.chat.length != obj.totalChat && showChatLoader) {
            page = page + 1;
            chatListing();
          }
        }
      });
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      print(e);
    });
  }

  Future<void> sendMsg() async {
    appendMsg();
    String sentOn = (now.hour > 12) ? '${now.hour - 12}:${now.minute.toString().length == 1 ? "0" + now.minute.toString() : now.minute} ${amPm}' : '${now.hour}:${now.minute} ${amPm}';
    socketRepo.clientSocket.value.emit("send_msg", {'from_id': currentUser.value.userId, 'to_id': userId, 'msg': msg, 'sent_on': sentOn});
    chatRepo.sendMsg(msg, userId);
  }
}
