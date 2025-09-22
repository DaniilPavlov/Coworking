import 'package:flutter/material.dart';

class LogoDecoration extends StatelessWidget {
  const LogoDecoration({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo.webp'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: child,
        ),
      ],
    );
  }
}
