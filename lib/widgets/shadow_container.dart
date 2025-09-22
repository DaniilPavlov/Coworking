import 'package:flutter/material.dart';

class ShadowContainer extends StatelessWidget {
  const ShadowContainer({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(
              4,
              4,
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}
