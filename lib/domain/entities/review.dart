import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/entities/pin.dart';

class Review {
  Review(
    this.id,
    this.author,
    this.body,
    this.timestamp,
    this.isFood,
    this.isFree,
    this.isRazors,
    this.isWiFi,
    this.userRate,
    this.totalRate,
  );
  String? id;
  final Account author;
  DateTime timestamp;
  Pin? pin;
  String body;
  bool isFood;
  bool isFree;
  bool isRazors;
  bool isWiFi;
  double userRate;
  double totalRate;

  Map<String, dynamic> asMap() {
    final Map<String, dynamic> review = {};
    review['author'] = author.id;
    review['dateAdded'] = Timestamp.fromDate(timestamp);
    review['content'] = body;
    review['pinID'] = pin?.id;
    review['isFood'] = isFood;
    review['isFree'] = isFree;
    review['isRazors'] = isRazors;
    review['isWiFi'] = isWiFi;
    review['userRate'] = userRate;
    review['totalRate'] = totalRate;
    return review;
  }

  static Map<String, dynamic> newReviewMap(Review review, String pinID) {
    final Map<String, dynamic> map = review.asMap();
    map['pinID'] = pinID;
    return map;
  }

  static Review fromMap(String id, Map<String, dynamic> data) {
    final date = data['dateAdded'] as Timestamp;
    return Review(
      id,
      Account(data['author']),
      data['content'],
      date.toDate(),
      data['isFood'],
      data['isFree'],
      data['isRazors'],
      data['isWiFi'],
      data['userRate'],
      data['totalRate'],
    );
  }
}
