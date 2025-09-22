import 'package:flutter/material.dart';

class BackgroundMeetings extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;
    final paint = Paint();

    final Path mainBackground = Path()
    ..addRect(Rect.fromLTRB(0, 0, screenWidth, screenHeight));
    paint.color = Colors.grey.shade100;
    canvas.drawPath(mainBackground, paint);

    // Yellow
    final Path yellowWave = Path()
    ..lineTo(0, screenHeight)
    ..lineTo(screenWidth, screenHeight)
    ..cubicTo(
      screenWidth * 0.6,
      screenHeight * 0.05,
      screenWidth * 0.27,
      screenHeight * 0.01,
      screenWidth * 0.18,
      screenHeight * 0.12,
    )
    ..quadraticBezierTo(
      screenWidth * 0.12,
      screenHeight * 0.2,
      0,
      screenHeight * 0.2,
    )
    ..close();
    paint.color = Colors.orange.shade300;
    canvas.drawPath(yellowWave, paint);

    // Blue
    final Path blueWave = Path()
    ..lineTo(screenWidth, 0)
    ..lineTo(screenWidth, screenHeight)
    ..quadraticBezierTo(
      screenWidth * 0.5,
      screenHeight * 0.75,
      screenWidth * 0.2,
      0,
    )
    ..close();
    paint.color = Colors.blue.shade300;
    canvas.drawPath(blueWave, paint);

    // Grey
    final Path greyWave = Path()
    ..lineTo(screenWidth, 0)
    ..lineTo(screenWidth, screenHeight * 0.1)
    ..cubicTo(
      screenWidth * 0.95,
      screenHeight * 0.15,
      screenWidth * 0.65,
      screenHeight * 0.15,
      screenWidth * 0.6,
      screenHeight * 0.38,
    )
    ..cubicTo(
      screenWidth * 0.52,
      screenHeight * 0.52,
      screenWidth * 0.05,
      screenHeight * 0.45,
      0,
      screenHeight * 0.4,
    )
    ..close();
    paint.color = Colors.grey.shade800;
    canvas.drawPath(greyWave, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
