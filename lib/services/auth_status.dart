import 'package:coworking/screens/login/logo_decoration.dart';
import 'package:flutter/material.dart';
import 'package:coworking/screens/login/login_screen.dart';
import 'package:coworking/screens/map/map_screen.dart';
import 'package:coworking/services/sign_in.dart';

class AuthStatus extends StatelessWidget {
  const AuthStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    doAuth() async {
      await SignIn().signInWithGoogle();
    }

    return FutureBuilder(
        future: SignIn().googleSignIn.isSignedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) doAuth();
            return (snapshot.data == true) ? MapScreen() : const LoginScreen();
          } else {
            return const LogoDecoration(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
