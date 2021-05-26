import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../screens/map/map.dart';
import 'sign_in.dart';

class AuthStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
