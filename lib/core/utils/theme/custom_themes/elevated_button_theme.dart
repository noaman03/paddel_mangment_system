import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class AElevatedButtonTheme {
  AElevatedButtonTheme._();

  static ElevatedButtonThemeData lightElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      // The accent green is too light to carry white text (1.91:1); the deep
      // brand green clears 4.5:1 while still reading as the same brand.
      backgroundColor: AColors.primaryDeep,
      foregroundColor: AColors.white,
      disabledBackgroundColor: AColors.borderPrimary,
      disabledForegroundColor: AColors.darkGrey,
      textStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
    ),
  );

  static ElevatedButtonThemeData darkElevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      // The accent green is too light to carry white text (1.91:1); the deep
      // brand green clears 4.5:1 while still reading as the same brand.
      backgroundColor: AColors.primaryDeep,
      foregroundColor: AColors.white,
      disabledBackgroundColor: AColors.borderDark,
      disabledForegroundColor: AColors.grey,
      textStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
    ),
  );
}
