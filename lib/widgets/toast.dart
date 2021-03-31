import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> buildToast(String message,
    {Color backgroundColor = Colors.deepPurple,
      Color textColor = Colors.white}) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      // timeInSecForIos: 2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0);
}
