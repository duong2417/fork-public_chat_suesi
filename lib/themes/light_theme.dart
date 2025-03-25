import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:public_chat/_shared/widgets/top_input_border.dart';
import 'base/color_base.dart';
import 'base/text_theme_base.dart';
import 'base/theme_base.dart';

ThemeData lightThemeDefault = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue[50],
    titleTextStyle: appTextStyle.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    enabledBorder: TopInputBorder(
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.2),
      ),
    ),
    focusedBorder: TopInputBorder(
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.2),
      ),
    ),
  ),
  scaffoldBackgroundColor: Colors.blue[50],
  extensions: [
    MyTextTheme(
      heading: appTextStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
      bodyMedium: appTextStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    ),
    const MyColorScheme(
      messageMeColor: Color(0xFF375fff),
      messageOtherColor: Colors.white, //
    ),
  ],
);
