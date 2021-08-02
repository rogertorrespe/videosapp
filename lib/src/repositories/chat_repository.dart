import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/chat_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<ChatModel> chatData = new ValueNotifier(ChatModel());
ValueNotifier<ChatModel> chatHistoryData = new ValueNotifier(ChatModel());

Future<ChatModel> chatListing(page, userId) async {
  if (page == 1) {
    chatData = new ValueNotifier(ChatModel());
    chatData.notifyListeners();
  }
  Uri uri = Helper.getUri('chats');
  uri = uri.replace(queryParameters: {'login_id': userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token, 'page': page.toString(), 'user_id': userId.toString()});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        print("response.body)['data']");
        print(json.decode(response.body)['data']);
        if (page > 1) {
          chatData.value.chat.insertAll(0, ChatModel.fromJson(json.decode(response.body)['data']).chat);
        } else {
          chatData.value = ChatModel.fromJson(json.decode(response.body)['data']);
        }
        chatData.notifyListeners();
        return chatData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    ChatModel.fromJson({});
  }
}

Future<ChatModel> chatHistoryListing(page) async {
  Uri uri = Helper.getUri('chat-history');
  uri = uri.replace(queryParameters: {'login_id': userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token, 'page': page.toString()});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        print("Print chat ");
        print(json.encode(jsonData));
        if (page > 1) {
          chatHistoryData.value.chat.insertAll(0, ChatModel.fromJson(json.decode(response.body)['data']).chat);
        } else {
          chatHistoryData.value = ChatModel.fromJson(json.decode(response.body)['data']);
        }
        chatHistoryData.notifyListeners();
        return chatData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    ChatModel.fromJson({});
  }
}

sendMsg(msg, userId) async {
  Uri uri = Helper.getUri('store-msg');
  uri = uri.replace(queryParameters: {
    'login_id': userRepo.currentUser.value.userId.toString(),
    "app_token": userRepo.currentUser.value.token,
    'msg': msg.toString(),
    'user_id': userId.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    await http.post(uri, headers: headers);
  } catch (e) {
    print(e.toString());
    ChatModel.fromJson({});
  }
}
