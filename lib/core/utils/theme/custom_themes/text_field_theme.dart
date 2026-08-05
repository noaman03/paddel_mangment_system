import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class ATextFormFieldTheme {
  ATextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AColors.white,
    errorMaxLines: 3,
    prefixIconColor: AColors.darkGrey,
    suffixIconColor: AColors.darkGrey,
    labelStyle: const TextStyle(
      color: AColors.textsecondarry,
      fontSize: 14.0,
    ),
    hintStyle: const TextStyle(
      color: AColors.darkGrey,
      fontSize: 14.0,
    ),
    errorStyle: const TextStyle(
      color: AColors.error,
      fontStyle: FontStyle.normal,
    ),
    floatingLabelStyle: const TextStyle(color: AColors.primaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.borderPrimary, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.borderPrimary, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.primaryColor, width: 2.0),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.borderSecondary, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.error, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.error, width: 1.0),
    ),
  );

  /// The dark input theme previously used a **white** fill with black hint
  /// text, while the dark text theme painted the typed text white — so
  /// everything the user typed was invisible. It now uses a dark elevated
  /// surface with light text.
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AColors.containerDarkElevated,
    errorMaxLines: 3,
    prefixIconColor: AColors.grey,
    suffixIconColor: AColors.grey,
    labelStyle: const TextStyle(
      color: AColors.textSecondaryDark,
      fontSize: 14.0,
    ),
    hintStyle: const TextStyle(
      color: AColors.grey,
      fontSize: 14.0,
    ),
    errorStyle: const TextStyle(
      color: AColors.error,
      fontStyle: FontStyle.normal,
    ),
    floatingLabelStyle: const TextStyle(color: AColors.primaryColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.borderDark, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.borderDark, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.primaryColor, width: 2.0),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.borderDark, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.error, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AColors.error, width: 1.0),
    ),
  );
}
