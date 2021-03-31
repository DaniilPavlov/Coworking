import 'dart:async';

import 'package:coworking/resources/review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


import 'database.dart';

class Account {
  static Account currentAccount;
  final String id;
  static Completer hasUpdated;

  String _userName;
  String _email;

  int _visitedCount;

  List<Review> _helpfulReviews = List<Review>();

  Account(
    this.id, {
    email,
    userName,
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
      return Database.getUserNameByID(id);
  }

  static updateUserName(String value) {
    hasUpdated = Completer();
    Account.currentAccount._userName = value;
    Database.updateUsername(value);

    FirebaseAuth.instance.currentUser().then((user) {
      var newInfo = UserUpdateInfo();
      newInfo.displayName = value;
      user.updateProfile(newInfo).then((_) {
        hasUpdated.complete();
      });
    });
  }

  int get visitedCount => _visitedCount;

  void incVisitedCount() {
    _visitedCount++;
    // TODO: update DB
  }

  List<Review> get helpful => _helpfulReviews;

  void addHelpful(Review review) {
    _helpfulReviews.add(review);
    // TODO: update DB
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> accountMap = Map();
    accountMap["userID"] = id;
    accountMap["name"] = _userName;
    accountMap["email"] = _email;
    accountMap["isAdmin"] = false;
    return accountMap;
  }

  static Stream<List<Review>> getReviewsForUser(BuildContext context) {
    return Database.reviewsByUser(currentAccount, context);
  }

  static Future<Stream<List<Review>>> getFavouriteReviewsForUser(
      BuildContext context) {
    return Database.favouriteReviewsForUser(currentAccount, context);
  }
}
