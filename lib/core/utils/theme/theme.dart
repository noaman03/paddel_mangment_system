import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/appbar_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/chip_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/text_field_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/text_theme.dart';

class appTheme {
  appTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    primarySwatch: AColors.primarySwatch,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: ATextTheme.lightTextTheme,
    elevatedButtonTheme: AElevatedButtonTheme.lightElevatedButtonTheme,
    chipTheme: AChipTheme.lightChipTheme,
    checkboxTheme: ACheckboxtheme.lightCheckboxTheme,
    bottomSheetTheme: ABottomSheetTheme.lightBottomSheetTheme,
    appBarTheme: AAppbarTheme.lightappbartheme,
    inputDecorationTheme: ATextFormFieldTheme.lightInputDecorationTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    primarySwatch: AColors.primarySwatch,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    textTheme: ATextTheme.darkTextTheme,
    elevatedButtonTheme: AElevatedButtonTheme.darkElevatedButtonTheme,
    chipTheme: AChipTheme.darkChipTheme,
    checkboxTheme: ACheckboxtheme.darkCheckboxTheme,
    bottomSheetTheme: ABottomSheetTheme.darkBottomSheetTheme,
    appBarTheme: AAppbarTheme.darkappbartheme,
    inputDecorationTheme: ATextFormFieldTheme.darkInputDecorationTheme,
  );
}
