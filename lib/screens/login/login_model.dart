import 'package:coworking/navigation/main_navigation.dart';
import 'package:coworking/services/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginModel extends ChangeNotifier {
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool _isAuthProgress = false;

  bool get canStartAuth => !_isAuthProgress;

  bool get isAuthProgress => _isAuthProgress;


  Future<void> auth(BuildContext context) async {
    _isAuthProgress = true;
    notifyListeners();
    User? user = await SignIn().signInWithGoogle();

    if (user == null) {
      print('Ошибка подключения');
      _errorMessage = "Ошибка подключения, попробуйте снова";
      _isAuthProgress = false;
      Scaffold.of(context).showBodyScrim(false, 0.5);
      notifyListeners();
      return;
    }
    _errorMessage = null;
    _isAuthProgress = false;
    notifyListeners();
    Navigator.of(context)
        .pushReplacementNamed(MainNavigationRouteNames.mapScreen);
  }

}
