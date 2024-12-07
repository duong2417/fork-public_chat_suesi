import 'package:flutter/material.dart';

class RoundedContainer extends Container {
  final Widget? child;
  final double width, widthBorder, borderRadius, paddingDouble;
  final Color? colorBorder, colorContainer;
  // final Color? colorContainer;

  RoundedContainer(
      {super.key,
      this.child,
      this.width = double.infinity,
      this.widthBorder=1,
      this.colorBorder,
      this.borderRadius = 20,
      this.colorContainer,
      this.paddingDouble = 16,
      super.margin,
      super.decoration,
      super.height});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        // padding: EdgeInsets.zero,
        // margin: EdgeInsets.only(top:10),
        padding: EdgeInsets.all(paddingDouble),
        decoration: BoxDecoration(
          color: colorContainer,
          border: Border.all(
              color: colorBorder ??const Color.fromARGB(255, 248, 244, 244),
              width: widthBorder), //compul
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        child: child);
  }
}
