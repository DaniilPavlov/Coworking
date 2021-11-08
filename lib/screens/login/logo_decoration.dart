import 'package:flutter/material.dart';

class LogoDecoration extends StatelessWidget {
  final Widget child;
  const LogoDecoration({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/logo.webp"),
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
