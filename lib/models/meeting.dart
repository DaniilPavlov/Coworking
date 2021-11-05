import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:coworking/models/account.dart';
import 'package:coworking/models/pin.dart';

class Meeting {
  String? id;
  String place;
  String description;
  Account author;
  Pin? pin;
  bool notify;
  List<String> members;
  List<String> tokens;
  Timestamp? dateCompleted;

  Meeting(
    this.id,
    this.place,
    this.description,
    this.author,
    this.members,
    this.tokens,
    this.dateCompleted,
    this.notify,
  );

  Meeting copy() {
    return Meeting(
      id,
      place,
      description,
      author,
      members,
      tokens,
      dateCompleted,
      notify,
    );
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> meeting = {};
    meeting["place"] = place;
    meeting["description"] = description;
    meeting["author"] = author.id;
    meeting["members"] = members;
    meeting["tokens"] = tokens;
    // meeting["pinID"] = pin?.id;
    meeting["dateCompleted"] = dateCompleted;
    meeting["notify"] = notify;
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
      data["place"] ,
      data["description"] ,
      Account(data["author"]  ),
      List<String>.from(data["members"]  ),
      List<String>.from(data["tokens"]  ),
      data["dateCompleted"]  ,
      data["notify"]  ,
    );
  }
}
