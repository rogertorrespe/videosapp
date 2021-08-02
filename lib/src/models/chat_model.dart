import 'package:Leuke/src/helpers/helper.dart';
import 'package:intl/intl.dart';

var formatterTime = new DateFormat('hh:mm a');
var formatterDate = new DateFormat('dd MMM yyyy');

class ChatModel {
  int totalChat = 0;
  List<Chat> chat = [];

  ChatModel();

  ChatModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      totalChat = jsonMap['total_records'] != null ? jsonMap['total_records'] : 0;
      chat = jsonMap['data'] != null ? parseData(jsonMap['data']) : [];
    } catch (e) {
      print("ChatModel.fromJson");
      print(e);
      totalChat = 0;
      chat = [];
    }
  }

  static List<Chat> parseData(jsonData) {
    List list = jsonData;
    List<Chat> attrList = list.map((data) => Chat.fromJSON(data)).toList();
    return attrList;
  }
}

class Chat {
  int chatId;

  int fromId;
  int toId;
  String msg;
  bool isRead;
  String sentOn;
  String sentDate;
  String sentDatetime;
  String username;
  String userDp;

  Chat();

  Chat.fromJSON(Map<String, dynamic> json) {
    chatId = json["chat_id"];
    fromId = json["from_id"] == null ? 0 : json["from_id"];
    toId = json["to_id"] == null ? 0 : json["to_id"];
    msg = json["msg"] == null ? '' : json["msg"];
    isRead = json["is_read"] == null
        ? false
        : json["is_read"] == 1
            ? true
            : false;
    // sentOn = json["sent_on"] == null ? '' : Helper.getYourCountryTime(DateFormat("HH:mm:ss").parse(json["sent_on"]));
    sentOn = json["sent_on"] == null ? '' : formatterTime.format(Helper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["sent_on"])));
    sentDate = json["sent_on"] == null ? '' : formatterDate.format(Helper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["sent_on"])));
    sentDatetime = json["sent_on"] == null ? '' : json["sent_on"];
    username = json["username"] == null ? '' : json["username"];
    userDp = json["user_dp"] == null ? '' : json["user_dp"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatId'] = this.chatId;
    data['fromId'] = this.fromId;
    data['toId'] = this.toId;
    data['msg'] = this.msg;
    data["isRead"] = this.isRead;
    data['sentOn'] = this.sentOn;
    data['username'] = this.username;
    data['userDp'] = this.userDp;
    return data;
  }
}
