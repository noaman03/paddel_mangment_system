import 'package:flutter/material.dart';
import 'package:padelsystem/core/const/colors.dart';

class AChipTheme {
  AChipTheme._();
  static ChipThemeData lightChipTheme = ChipThemeData(
    selectedColor: AColors.primaryColor,
    disabledColor: Colors.grey.withOpacity(0.4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    labelStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
    checkmarkColor: Colors.white,
  );
  static ChipThemeData darkChipTheme = ChipThemeData(
    selectedColor: AColors.primaryColor,
    disabledColor: Colors.grey.withOpacity(0.4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    labelStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
    checkmarkColor: Colors.white,
  );
}
