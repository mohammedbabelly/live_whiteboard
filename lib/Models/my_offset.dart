import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_whiteboard/Helpers/constants.dart';

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

  Offset toLocalOffset(RenderBox box) => box.globalToLocal(Offset(x, y));
  Offset toOffset() =>
      Offset(Constants.screenWidth / x, Constants.screenHeight / y);

  factory MyOffset.fromOffset(Offset? offset) =>
      MyOffset(offset!.dx, offset.dy);
  factory MyOffset.fromJson(Map<String, dynamic> json) =>
      MyOffset(json["x"].toDouble(), json["y"].toDouble());

  Map<String, dynamic> toJson() => {"x": x, "y": y};
}

class MyRenderBox extends RenderBox {}
