import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/resources/pin.dart';
import 'package:coworking/resources/database.dart';

import 'account.dart';

class Review {
  String id;

  final Account author;
  final DateTime timestamp;

  Pin pin; // set by review when adopted

  String body;

  int _flagCount;


  Review(this.id, this.author, this.body, this.timestamp, this._flagCount,
      );

  // String get body => _body;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return id == other.id;
  }

  // void updateBody(String value) {
  //   _body = value;
  //   // TODO: update DB
  // }

  int get flagCount => _flagCount;

  void incFlagCount() {
    _flagCount++;
    // TODO: update DB
  }

  // Future<String> get reviewContent async {
  //   if (_body != null)
  //     return _body;
  //   else
  //     return Database.getReviewContentByID(id);
  // }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> review = Map();
    review["author"] = author.id;
    review["dateAdded"] = Timestamp.fromDate(timestamp);
    review["content"] = body;
    review["flagCount"] = _flagCount;
    review["pinID"] = pin?.id;
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
      data["flagCount"],
    );
  }
}
