import 'package:flutter/material.dart';

class MyTextTheme extends ThemeExtension<MyTextTheme> {
  const MyTextTheme({
    this.bodyMedium,
    this.heading,
  });
  final TextStyle? bodyMedium;
  final TextStyle? heading;

  // Base text theme configuration

  @override
  ThemeExtension<MyTextTheme> copyWith() {
    return MyTextTheme(
      bodyMedium: bodyMedium,
      heading: heading,
    );
  }

  @override
  ThemeExtension<MyTextTheme> lerp(
      covariant ThemeExtension<MyTextTheme>? other, double t) {
    if (other is! MyTextTheme) return this;
    return MyTextTheme(
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t),
      heading: TextStyle.lerp(heading, other.heading, t),
    );
  }
}
