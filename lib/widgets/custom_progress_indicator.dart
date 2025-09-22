import 'package:flutter/material.dart';

// TODO(feature): replace CircularProgressIndicator with this widget
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
