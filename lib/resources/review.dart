import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/resources/pin.dart';

import 'account.dart';

class Review {
  String id;

  final Account author;
  final DateTime timestamp;

  Pin pin;
  String body;

  bool isFood;
  bool isFree;
  bool isRazors;
  bool isWiFi;
  double userRate;
  double totalRate;

  Review(this.id,
      this.author,
      this.body,
      this.timestamp,
      this.isFood,
      this.isFree,
      this.isRazors,
      this.isWiFi,
      this.userRate,
      this.totalRate);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return id == other.id;
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> review = Map();
    review["author"] = author.id;
    review["dateAdded"] = Timestamp.fromDate(timestamp);
    review["content"] = body;
    review["pinID"] = pin?.id;
    review["isFood"] = isFood;
    review["isFree"] = isFree;
    review["isRazors"] = isRazors;
    review["isWiFi"] = isWiFi;
    review["userRate"] = userRate;
    review["totalRate"] = totalRate;
    return review;
  }

  static Map<String, dynamic> newReviewMap(Review review, String pinID) {
    Map<String, dynamic> map = review.asMap();
    map["pinID"] = pinID;
    return map;
  }

  static Review fromMap(String id, Map<String, dynamic> data) {
    return Review(
      id,
      Account(data["author"]),
      data["content"],
      data["dateAdded"].toDate(),
      data["isFood"],
      data["isFree"],
      data["isRazors"],
      data["isWiFi"],
      data["userRate"],
      data["totalRate"]
    );
  }
}
