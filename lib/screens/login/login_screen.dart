import 'package:auth_buttons/auth_buttons.dart';
import 'package:coworking/screens/login/error_message_widget.dart';
import 'package:coworking/screens/login/login_model.dart';
import 'package:coworking/screens/login/logo_decoration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  //в инхерит передается значение и может использоваться лишь стейтфул виджет.
  //в провайдере же передается сама модель, чтобы произошло замыкание и даже
  //стейтлесс виджет мог хранить изменяемые значения

  //change notifier provider сам у себя вызывает диспоуз и у модели,
  //когда мы закрываем экран. руками писать не нужно
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => LoginModel(),
        //true = модель создасться лишь тогда, когда мы впервые к ней обратимся
        //false = модель создается сразу
        lazy: true,
        child: const _LoginView(),
      );
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  void startAuth(BuildContext context) {
    final model = context.read<LoginModel>();
    if (model.canStartAuth) {
      model.auth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LogoDecoration(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 140, left: 20, right: 20),
              child: Align(
                child: Text(
                  'Добро пожаловать в Work Space!',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 50,
              child: Builder(
                builder: (context) => GoogleAuthButton(
                  onPressed: () => startAuth(context),
                ),
              ),
            ),
            Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 30, left: 40, right: 40),
              child: ErrorMessageWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
