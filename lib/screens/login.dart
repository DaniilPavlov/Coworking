import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import '../sign_in.dart';
import 'map.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: SizedBox.expand(
            child: Card(
              margin: MediaQuery.of(context).padding +
                  EdgeInsets.symmetric(vertical: 128.0, horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "Study Together",
                    textScaleFactor: 3.0,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Image.asset("assets/logo.png"),
                  ),
                  Builder(
                    builder: (context) => GoogleSignInButton(
                      onPressed: () async {
                        Scaffold.of(context).showBodyScrim(true, 0.5);
                        setState(() {
                          isLoading = true;
                        });
                        FirebaseUser user = await SignIn().signInWithGoogle();
                        setState(() {
                          isLoading = false;
                        });

                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => MapPage()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                strokeWidth: 10.0,
                semanticsLabel: "Signing in",
              ),
            ),
          ),
          visible: isLoading,
        ),
      ],
    );
  }
}
