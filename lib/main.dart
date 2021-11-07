import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coworking/services/auth_status.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WorkSpace',
        theme: ThemeData(
          primaryColor: Colors.orange,
          primarySwatch: Colors.orange,
          bottomSheetTheme: const BottomSheetThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
          ),
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: Colors.orange),
        ),
        home: FutureBuilder(
          future: getData(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const AuthStatusScreen();
            } else if (snapshot.connectionState == ConnectionState.none) {
              return const Text("No connection with Server");
            }
            return const CircularProgressIndicator();
          },
        ));
  }

  Future<DocumentSnapshot> getData() async {
    await Firebase.initializeApp();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc("docID")
        .get();
  }
}
