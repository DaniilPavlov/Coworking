import 'package:flutter/material.dart';

import 'option.dart';


class Tag extends Option {
  Tag(String name, Color colour) : super(text: name, colour: colour);

  // TODO: добавить больше ячеек
  static List<Tag> all() => [
        Tag("Бесплатно", Colors.purple),
        Tag("Есть розетки", Colors.blue),
        Tag("Можно перекусить", Colors.green),
      ];

  Map<String, String> asMap() {
    return {"name": this.text};
  }

  static Tag find(String text) => Tag.all().firstWhere(
        (test) => test.text == text,
  );
}
