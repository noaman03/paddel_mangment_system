import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class AChipTheme {
  AChipTheme._();

  /// A plain `TextStyle` here would also be applied to the *selected* chip, so
  /// the label kept its unselected colour on top of the green fill and
  /// disappeared. Resolving per state is what makes the selected label legible.
  static WidgetStateTextStyle _label(Color unselected) =>
      WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AColors.foregroundOn(AColors.primaryDeep)
              : unselected,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
      );

  static ChipThemeData lightChipTheme = ChipThemeData(
    backgroundColor: AColors.softGrey,
    selectedColor: AColors.primaryDeep,
    disabledColor: AColors.borderSecondary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    labelStyle: _label(AColors.textprimary),
    secondaryLabelStyle: _label(AColors.textprimary),
    checkmarkColor: AColors.white,
    side: const BorderSide(color: AColors.borderPrimary),
    shape: const StadiumBorder(),
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    backgroundColor: AColors.containerDarkElevated,
    selectedColor: AColors.primaryDeep,
    disabledColor: AColors.borderDark,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    labelStyle: _label(AColors.textPrimaryDark),
    secondaryLabelStyle: _label(AColors.textPrimaryDark),
    checkmarkColor: AColors.white,
    side: const BorderSide(color: AColors.borderDark),
    shape: const StadiumBorder(),
  );
}
