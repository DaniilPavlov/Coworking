import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:auth_buttons/auth_buttons.dart';

import 'package:coworking/services/sign_in.dart';
import 'package:coworking/screens/map/map.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/logo.webp"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 140, left: 20, right: 20),
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
         const  SizedBox(height: 50),
          SizedBox(
            child: Builder(
              builder: (context) => GoogleAuthButton(
                onPressed: () async {
                  Scaffold.of(context).showBodyScrim(true, 0.5);
                  setState(() {
                    isLoading = true;
                  });
                  User? user = await SignIn().signInWithGoogle();
                  setState(() {
                    isLoading = false;
                  });
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MapPage()),
                    );
                  } else {
                    Scaffold.of(context).showBodyScrim(false, 0.5);
                  }
                },
              ),
            ),
            height: 50,
          ),
          Visibility(
            child: Container(
              alignment: Alignment.center,
              child: const SizedBox(
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
