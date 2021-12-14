import 'package:flutter/material.dart';

import 'package:coworking/domain/entities/option.dart';

class Category extends Option {
  Category(String name, Color colour) : super(text: name, colour: colour);

  static List<Category> all() => [
        Category("Парк", Colors.green),
        Category("Кафе", Colors.grey),
        Category("Библиотека", Colors.blueGrey),
        Category("Коворкинг", Colors.blue),
      ];

  static Category find(String text) => Category.all().firstWhere(
        (test) => test.text == text,
      );
}
