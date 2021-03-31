import 'package:flutter/widgets.dart';

class Option {
  String text;
  Color colour;

  Option({this.text, this.colour});

  @override
  bool operator ==(Object other) => other is Option && other.text == this.text;

  @override
  int get hashCode => this.text.hashCode;
}
