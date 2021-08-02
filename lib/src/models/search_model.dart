import 'hash_videos_model.dart';
import 'videos_model.dart';

class SearchModel {
  // int totalRecords = 0;
  List<Video> users = [];
  List<Videos> videos = [];
  List<dynamic> hashTags = [];

  SearchModel();

  SearchModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      print("jsonMap from json");
      print(jsonMap);
      print("jsonMap['users']");
      print(jsonMap['users']);
      print("jsonMap['videos']");
      print(jsonMap['videos']);
      print("jsonMap['hashTags']");
      print(jsonMap['hashTags']);
      // totalRecords = jsonMap['total'] != null ? jsonMap['total'] : 0;
      users = jsonMap['users'] != null ? parseUsersAttributes(jsonMap['users']) : [];
      videos = jsonMap['videos'] != null ? parseVideoAttributes(jsonMap['videos']) : [];
      hashTags = jsonMap['hashTags'] != null ? jsonMap['hashTags'] : [];
    } catch (e) {
      print("search model error $e");
      // totalRecords = 0;
      videos = [];
      users = [];
    }
  }

  static List<Video> parseUsersAttributes(jsonData) {
    try {
      List list = jsonData;
      List<Video> attrList = list.map((data) => Video.fromJSON(data)).toList();
      return attrList;
    } catch (e) {
      print("search model Users error $e");
    }
  }

  static List<Videos> parseVideoAttributes(attributesJson) {
    try {
      List list = attributesJson;
      List<Videos> attrList = list.map((data) => Videos.fromJSON(data)).toList();
      return attrList;
    } catch (e) {
      print("search model video error $e");
    }
  }
}

class Banners {
  int id;
  String tag;
  String banner;

  Banners.fromJSON(Map<String, dynamic> json) {
    id = json["tag_id"];
    tag = json["tag"] == null ? '' : json["tag"];
    banner = json["banner"] == null ? '' : json["banner"];
  }
}
