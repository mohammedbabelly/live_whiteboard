import 'dart:convert';

import 'package:flutter/material.dart';

void main() => runApp(new MaterialApp(
      home: new HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Offset?> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              var newOffset =
                  MyOffset(details.localPosition.dx, details.localPosition.dy);
              var encoded = newOffset.toRawJson();
              MyOffset decoded = MyOffset.fromRawJson(encoded);
              _points = new List.from(_points)..add(decoded.toOffset());
            });
          },
          onPanEnd: (DragEndDetails details) {
            _points.add(null);
          },
          child: new CustomPaint(
            painter: new Signature(_points),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.clear),
        onPressed: () => _points.clear(),
      ),
    );
  }
}

class Signature extends CustomPainter {
  List<Offset?> points;

  Signature(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}

class MyOffset {
  MyOffset(
    this.x,
    this.y,
  );

  final double x;
  final double y;

  factory MyOffset.fromRawJson(String str) =>
      MyOffset.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  Offset toOffset() => Offset(x, y);

  factory MyOffset.fromJson(Map<String, dynamic> json) => MyOffset(
        json["x"].toDouble(),
        json["y"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}
