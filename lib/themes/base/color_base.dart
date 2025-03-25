import 'package:flutter/material.dart';

class MyColorScheme extends ThemeExtension<MyColorScheme> {
  const MyColorScheme({
    this.messageMeColor,
    this.messageOtherColor,
  });

  final Color? messageMeColor;
  final Color? messageOtherColor;
  @override
  ThemeExtension<MyColorScheme> copyWith() {
    return MyColorScheme(
      messageMeColor: messageMeColor,
      messageOtherColor: messageOtherColor,
    );
  }

  @override
  ThemeExtension<MyColorScheme> lerp(
      ThemeExtension<MyColorScheme>? other, double t) {
    if (other is! MyColorScheme) {
      return this;
    }
    return MyColorScheme(
      messageMeColor: Color.lerp(messageMeColor, other.messageMeColor, t),
      messageOtherColor:
          Color.lerp(messageOtherColor, other.messageOtherColor, t),
    );
  }
}
