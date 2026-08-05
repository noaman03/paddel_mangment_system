import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class ACheckboxtheme {
  ACheckboxtheme._();

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    side: const BorderSide(color: AColors.borderPrimary, width: 1.6),
    checkColor: const WidgetStatePropertyAll<Color>(AColors.white),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AColors.primaryColor;
      return Colors.transparent;
    }),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    side: const BorderSide(color: AColors.borderDark, width: 1.6),
    checkColor: const WidgetStatePropertyAll<Color>(AColors.white),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AColors.primaryColor;
      return Colors.transparent;
    }),
  );
}
