import 'package:flutter/widgets.dart';

@immutable
// ignore: must_be_immutable
class Option {
  Option({required this.text, required this.colour});
  String text;
  Color colour;

  @override
  bool operator ==(Object other) => other is Option && other.text == text;

  @override
  int get hashCode => text.hashCode;
}
