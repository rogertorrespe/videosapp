import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../repositories/chat_repository.dart' as chatRepo;

class ChatListController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  final msgController = TextEditingController();
  DateTime now = DateTime.now();
  ScrollController scrollController = new ScrollController();
  ValueNotifier<bool> loadMoreUpdateView = new ValueNotifier(false);
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  bool showChatLoader = true;
  bool showLoad = false;
  int page = 1;
  ChatListController() {
    scrollController = new ScrollController();
  }

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> chatHistoryListing(page) async {
    if (page > 1) {
      showLoader.value = true;
      showLoader.notifyListeners();
    } else {
      showLoad = true;
    }
    chatRepo.chatHistoryListing(page).then((obj) {
      showLoad = false;
      if (page > 1) {
        showLoader.value = false;
        showLoader.notifyListeners();
        loadMoreUpdateView.value = true;
        loadMoreUpdateView.notifyListeners();
      }
      if (obj.totalChat == obj.chat.length) {
        showChatLoader = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == 0) {
          if (obj.chat.length != obj.totalChat && showChatLoader) {
            page = page + 1;
            chatHistoryListing(page);
          }
        }
      });
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      print(e);
    });
  }
}
