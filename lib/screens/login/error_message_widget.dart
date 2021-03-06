import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coworking/screens/login/login_model.dart';

class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoginModel>();
    if (model.errorMessage == null && model.isAuthProgress == false) {
      return const SizedBox.shrink();
    }
    if (model.isAuthProgress) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black45,
                    offset: Offset(-5, 5),
                    blurRadius: 10,
                    spreadRadius: 1),
              ]),
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Center(
            child: Text(
              model.errorMessage!,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }
}
