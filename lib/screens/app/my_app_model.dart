import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/services/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MyAppModel extends ChangeNotifier {
  static bool isAuth = false;

  static Future<bool> doFirebaseConnection() async {
    await Firebase.initializeApp();
    try {
      await FirebaseFirestore.instance.collection("users").doc("docID").get();
      isAuth = await SignIn().googleSignIn.isSignedIn();
      if (isAuth) {
        await SignIn().signInWithGoogle();
      }
      return true;
    } catch (e) {
      isAuth = false;
      return false;
    }
  }

//TODO
  Future<void> resetSession(BuildContext context) async {}
}
