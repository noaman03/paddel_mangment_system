import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class ACheckboxtheme {
  ACheckboxtheme._();
  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((States) {
      if (States.contains(WidgetState.selected)) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((States) {
      if (States.contains(WidgetState.selected)) {
        return AColors.primaryColor;
      } else {
        return Colors.transparent;
      }
    }),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith((States) {
      if (States.contains(WidgetState.selected)) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((States) {
      if (States.contains(WidgetState.selected)) {
        return AColors.primaryColor;
      } else {
        return Colors.transparent;
      }
    }),
  );
}
