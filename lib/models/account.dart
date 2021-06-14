import 'dart:async';

import 'package:coworking/models/review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../services/database_meeting.dart';
import '../services/database_map.dart';
import 'meeting.dart';

class Account {
  static Account currentAccount;
  String id;
  static Completer hasUpdated;

  String _userName;
  String _email;
  String notifyToken;

  Account(
    this.id, {
    email,
    userName,
    String notifyToken,
  }) {
    this._email = email;
    this._userName = userName;
  }

  static Account fromFirebaseUser(FirebaseUser user) {
    return Account(
      user.uid,
      email: user.email,
      userName: user.displayName,
    );
  }

  Future<String> get userName async {
    if (_userName != null)
      return _userName;
    else
      return DatabaseMap.getUserNameByID(id);
  }

  static updateUserName(String value) {
    hasUpdated = Completer();
    Account.currentAccount._userName = value;
    DatabaseMap.updateUsername(value);

    FirebaseAuth.instance.currentUser().then((user) {
      var newInfo = UserUpdateInfo();
      newInfo.displayName = value;
      user.updateProfile(newInfo).then((_) {
        hasUpdated.complete();
      });
    });
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> accountMap = Map();
    accountMap["userID"] = id;
    accountMap["name"] = _userName;
    accountMap["email"] = _email;
    accountMap["isAdmin"] = false;
    accountMap["notifyToken"] = notifyToken;
    return accountMap;
  }

  static Stream<List<Review>> getReviewsForUser(BuildContext context) {
    return DatabaseMap.reviewsByUser(currentAccount, context);
  }

  static Stream<List<Meeting>> getMeetingsForUser(BuildContext context) {
    return DatabaseMeeting.meetingsOfUser(currentAccount, context);
  }

  static Future<Stream<List<Review>>> getFavouriteReviewsForUser(
      BuildContext context) {
    return DatabaseMap.favouriteReviewsForUser(currentAccount, context);
  }
}
