import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../_shared/widgets/top_input_border.dart';
import 'base/color_base.dart';
import 'base/text_theme_base.dart';
import 'base/theme_base.dart';

ThemeData darkThemeDefault = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0x0f0f1828),
    titleTextStyle: appTextStyle.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.black,
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
  scaffoldBackgroundColor: Colors.black,
  extensions: [
    MyTextTheme(
      heading: appTextStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blue[100],
      ),

      /// bodyMedium
      bodyMedium: appTextStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    ),
    const MyColorScheme(
      messageMeColor: Color(0xFF375fff),
      messageOtherColor: Color(0xff0f1828),
    ),
  ],
);
