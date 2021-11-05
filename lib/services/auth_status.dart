import 'package:flutter/material.dart';
import 'package:coworking/screens/login.dart';
import 'package:coworking/screens/map/map.dart';
import 'package:coworking/services/sign_in.dart';

class AuthStatusScreen extends StatelessWidget {
  const AuthStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    doAuth() async {
      await SignIn().signInWithGoogle();
    }

    return FutureBuilder(
        future: SignIn().googleSignIn.isSignedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) doAuth();
            // return LoginScreen();
            return (snapshot.data) != null ? MapPage() : const LoginScreen();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
