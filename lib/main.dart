import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coworking/screens/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Together',
      theme: ThemeData(
        // textSelectionHandleColor: Colors.deepPurple,
        // textSelectionColor: Colors.deepPurple,
        // cursorColor: Colors.deepPurple,
        primaryColor: Colors.orange,
        // textTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
        primarySwatch: Colors.orange,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
