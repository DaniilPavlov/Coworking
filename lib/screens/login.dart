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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/logo.webp"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 140, left: 20, right: 20),
            child: Container(
              child: Align(
                child: Text(
                  'Добро пожаловать в Work Space!',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
          Container(
            child: Builder(
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
            height: 50,
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
        ]),
      ),
    );
  }
}
