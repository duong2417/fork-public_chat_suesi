import 'package:flutter/material.dart';

class TopInputBorder extends InputBorder {
  @override
  // ignore: overridden_fields
  final BorderSide borderSide;

  const TopInputBorder({required this.borderSide}) : super();

  @override
  TopInputBorder copyWith({BorderSide? borderSide}) {
    return TopInputBorder(borderSide: borderSide ?? this.borderSide);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(top: borderSide.width);

  @override
  bool get isOutline => true;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final Paint paint = borderSide.toPaint();
    // Vẽ đường thẳng từ góc trái đến góc phải của phần top
    canvas.drawLine(rect.topLeft, rect.topRight, paint);
  }

  @override
  TopInputBorder scale(double t) {
    return TopInputBorder(borderSide: borderSide.scale(t));
  }
}
