import 'package:flutter/material.dart';
import 'login.dart';
import 'map.dart';
import '../sign_in.dart';
import 'package:coworking/resources/account.dart';

class AuthStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Account.currentAccount != null) {
      SignIn().signInWithGoogle();
    }
    return (Account.currentAccount != null) ? MapPage() : LoginScreen();
  }
}
