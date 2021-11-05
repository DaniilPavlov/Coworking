import 'package:flutter/widgets.dart';

class Option {
  String text;
  Color colour;

  Option({required this.text, required this.colour});

  @override
  bool operator ==(Object other) => other is Option && other.text == text;

  @override
  int get hashCode => text.hashCode;
}
