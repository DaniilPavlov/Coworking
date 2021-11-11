import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/app/my_app_model.dart';
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
      initialRoute: mainNavigation.initialRoute(MyAppModel.isAuth == false),
      routes: mainNavigation.routes,
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }
}
