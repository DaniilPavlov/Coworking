import 'package:flutter/material.dart';

import 'option.dart';

class Category extends Option {
  Category(String name, Color colour) : super(text: name, colour: colour);

// TODO: добавить больше ячеек
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
