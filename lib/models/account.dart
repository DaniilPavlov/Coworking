import 'dart:async';

import 'package:coworking/models/review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:coworking/services/database_meeting.dart';
import 'package:coworking/services/database_map.dart';
import 'package:coworking/models/meeting.dart';

class Account {
  static Account? currentAccount;
  String? id;

  String? _userName;
  String? _email;
  String? notifyToken;
  static Completer? hasUpdated;

  Account(
    this.id, {
    email,
    userName,
    notifyToken,
  }) {
    _email = email;
    _userName = userName;
  }

  static Account fromFirebaseUser(User user) {
    return Account(
      user.uid,
      email: user.email,
      userName: user.displayName,
    );
  }

  Future<String?> get userName async => await DatabaseMap.getUserNameByID(id!);

  static updateUserName(String value) {
    FirebaseAuth.instance.currentUser!.updateDisplayName(value);
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> accountMap = {};
    accountMap["userID"] = id;
    accountMap["name"] = _userName;
    accountMap["email"] = _email;
    accountMap["isAdmin"] = false;
    accountMap["notifyToken"] = notifyToken;
    return accountMap;
  }

  static Stream<List<Review>> getReviewsForUser(BuildContext context) {
    return DatabaseMap.reviewsByUser(currentAccount!, context);
  }

  static Stream<List<Meeting>> getMeetingsForUser(BuildContext context) {
    return DatabaseMeeting.meetingsOfUser(currentAccount!, context);
  }

  static Future<Stream<List<Review>>> getFavouriteReviewsForUser(
      BuildContext context) {
    return DatabaseMap.favouriteReviewsForUser(currentAccount!, context);
  }
}
