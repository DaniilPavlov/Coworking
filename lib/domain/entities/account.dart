import 'dart:async';
import 'package:coworking/domain/services/database_account.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Account {
  Account(
    this.id, {
    email,
    userName,
  }) {
    _email = email;
    _userName = userName;
  }
  static Account? currentAccount;
  String id;

  String? _userName;
  String? _email;
  String? notifyToken;
  static Completer? hasUpdated;

  static Account fromFirebaseUser(User user) {
    return Account(
      user.uid,
      email: user.email,
      userName: user.displayName,
    );
  }

  Future<String?> get userName async {
    if (_userName != null) {
      return _userName!;
    } else {
      return DatabaseAccount.fetchUserNameByID(id);
    }
  }

  Map<String, dynamic> asMap() {
    final Map<String, dynamic> accountMap = {};
    accountMap['userID'] = id;
    accountMap['name'] = _userName;
    accountMap['email'] = _email;
    accountMap['isAdmin'] = false;
    accountMap['notifyToken'] = notifyToken;
    return accountMap;
  }
}
