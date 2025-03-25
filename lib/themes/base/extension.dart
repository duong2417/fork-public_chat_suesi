import 'package:flutter/material.dart';
import 'color_base.dart';
import 'text_theme_base.dart';

extension CustomTextStyles on BuildContext {
  MyTextTheme get myTextTheme =>
      Theme.of(this).extension<MyTextTheme>() ?? const MyTextTheme();
  MyColorScheme get myColorScheme =>
      Theme.of(this).extension<MyColorScheme>() ?? const MyColorScheme();
}
