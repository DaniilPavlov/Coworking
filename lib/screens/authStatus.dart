import 'package:flutter/material.dart';
import 'login.dart';
import 'map.dart';
import '../sign_in.dart';

class AuthStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ///нужно проверить на удалении
    doAuth() async {
      await SignIn().signInWithGoogle();
    }

    return FutureBuilder(
        future: SignIn().googleSignIn.isSignedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) doAuth();
            return (snapshot.data) ? MapPage() : LoginScreen();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
