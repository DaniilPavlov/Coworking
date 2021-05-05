import 'package:cloud_firestore/cloud_firestore.dart';

import 'account.dart';
import 'pin.dart';

class Meeting {
  String id;
  String place;
  String description;
  Account author;
  Pin pin;

  // List<String> members;
  // List<String> tokens;
  Timestamp dateCompleted;

  Meeting(
    this.id,
    this.place,
    this.description,
    this.author,
    // this.members,
    // this.tokens,
    this.dateCompleted,
  );

  Meeting copy() {
    return Meeting(
      this.id,
      this.place,
      this.description,
      this.author,
      this.dateCompleted,
    );
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> meeting = Map();
    meeting["place"] = place;
    meeting["description"] = description;
    meeting["author"] = author.id;
    // meeting["members"] = members;
    // meeting["tokens"] = tokens;
    // meeting["pinID"] = pin?.id;
    meeting["dateCompleted"] = dateCompleted;
    return meeting;
  }

  // static Map<String, dynamic> newMeetingMap(Meeting meeting, String pinID) {
  //   Map<String, dynamic> map = meeting.asMap();
  //   map["pinID"] = pinID;
  //   return map;
  // }

  static Meeting fromMap(String id, Map<String, dynamic> data) {
    return Meeting(
      id,
      data["place"],
      data["description"],
      Account(data["author"]),
      data["dateCompleted"],
    );
  }
}
