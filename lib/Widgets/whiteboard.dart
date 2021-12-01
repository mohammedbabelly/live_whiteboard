import 'package:flutter/material.dart';
import 'package:live_whiteboard/Models/my_offset.dart';

class WhiteBoard extends CustomPainter {
  List<MyOffset?> points;

  WhiteBoard(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      // ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.toOffset(), points[i + 1]!.toOffset(),
            paint..color = points[i]!.color);
      }
    }
  }

  @override
  bool shouldRepaint(WhiteBoard oldDelegate) => oldDelegate.points != points;
}
