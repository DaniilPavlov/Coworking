import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coworking/services/auth_status.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkSpace',
      theme: ThemeData(
        cursorColor: Colors.orange,
        primaryColor: Colors.orange,
        primarySwatch: Colors.orange,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
        ),
      ),
      home: AuthStatusScreen(),
    );
  }
}
