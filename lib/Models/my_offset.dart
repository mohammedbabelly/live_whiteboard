import 'dart:convert';

import 'package:flutter/material.dart';

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

  factory MyOffset.fromOffset(Offset? offset) =>
      MyOffset(offset!.dx, offset.dy);
  factory MyOffset.fromJson(Map<String, dynamic> json) =>
      MyOffset(json["x"].toDouble(), json["y"].toDouble());

  Map<String, dynamic> toJson() => {"x": x, "y": y};
}
