import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/services/auth_status.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  static final mainNavigation = MainNavigation();

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
            return const AuthStatus();
          } else if (snapshot.connectionState == ConnectionState.none) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/logo.webp"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(child: Text("No connection with Server")),
            );
          }
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logo.webp"),
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
      routes: mainNavigation.routes,
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }

  Future<DocumentSnapshot> getData() async {
    await Firebase.initializeApp();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc("docID")
        .get();
  }
}
