import 'package:flutter/material.dart';

class BackgroundMeetings extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var screenWidth = size.width;
    var screenHeight = size.height;
    var paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, screenWidth, screenHeight));
    paint.color = Colors.grey.shade100;
    canvas.drawPath(mainBackground, paint);

    // Yellow
    Path yellowWave = Path();
    yellowWave.lineTo(0, screenHeight);
    yellowWave.lineTo(screenWidth, screenHeight);
    yellowWave.cubicTo(
        screenWidth * 0.6,
        screenHeight * 0.05,
        screenWidth * 0.27,
        screenHeight * 0.01,
        screenWidth * 0.18,
        screenHeight * 0.12);
    yellowWave.quadraticBezierTo(
        screenWidth * 0.12, screenHeight * 0.2, 0, screenHeight * 0.2);
    yellowWave.close();
    paint.color = Colors.orange.shade300;
    canvas.drawPath(yellowWave, paint);

    // Blue
    Path blueWave = Path();
    blueWave.lineTo(screenWidth, 0);
    blueWave.lineTo(screenWidth, screenHeight);
    blueWave.quadraticBezierTo(
        screenWidth * 0.5, screenHeight * 0.75, screenWidth * 0.2, 0);
    blueWave.close();
    paint.color = Colors.blue.shade300;
    canvas.drawPath(blueWave, paint);

    // Grey
    Path greyWave = Path();
    greyWave.lineTo(screenWidth, 0);
    greyWave.lineTo(screenWidth, screenHeight * 0.1);
    greyWave.cubicTo(
        screenWidth * 0.95,
        screenHeight * 0.15,
        screenWidth * 0.65,
        screenHeight * 0.15,
        screenWidth * 0.6,
        screenHeight * 0.38);
    greyWave.cubicTo(screenWidth * 0.52, screenHeight * 0.52,
        screenWidth * 0.05, screenHeight * 0.45, 0, screenHeight * 0.4);
    greyWave.close();
    paint.color = Colors.grey.shade800;
    canvas.drawPath(greyWave, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
