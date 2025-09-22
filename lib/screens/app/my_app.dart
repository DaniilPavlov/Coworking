import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/screens/app/my_app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final mainNavigation = MainNavigation();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkSpace',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.orange,
        primarySwatch: Colors.orange,
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.orange),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange,
        primarySwatch: Colors.orange,
        canvasColor: Colors.black,
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.orange),
      ),
      themeMode: ThemeMode.dark,
      initialRoute: mainNavigation.initialRoute(!MyAppModel.isAuth),
      routes: mainNavigation.routes,
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }
}
