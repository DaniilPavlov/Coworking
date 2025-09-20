import 'package:flutter/material.dart';

// TODO побаловаться с ним и внедрить вместо обычного CircularProgressIndicator
class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const CircularProgressIndicator(),
    );
  }
}
