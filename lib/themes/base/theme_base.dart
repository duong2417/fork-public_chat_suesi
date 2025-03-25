import 'package:flutter/material.dart';

import '../dark_theme.dart';
import '../light_theme.dart';

TextStyle appTextStyle = const TextStyle(
  fontFamily: 'SFProDisplay',
);

class ThemeBase {
  static ThemeData lightTheme = lightThemeDefault;
  static ThemeData darkTheme = darkThemeDefault;
}