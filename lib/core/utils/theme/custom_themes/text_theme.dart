import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class ATextTheme {
  ATextTheme._();

  static const String fontFamily = 'Roboto';

  static TextTheme _build(Color primary, Color secondary) => TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w800,
          height: 1.15,
          color: primary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: primary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: primary,
        ),
        titleLarge: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        titleMedium: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleSmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: primary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          height: 1.4,
          color: primary,
        ),
        bodySmall: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: secondary,
        ),
        labelLarge: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        labelMedium: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
      );

  static final TextTheme lightTextTheme =
      _build(AColors.textprimary, AColors.textsecondarry);

  static final TextTheme darkTextTheme =
      _build(AColors.textPrimaryDark, AColors.textSecondaryDark);
}
