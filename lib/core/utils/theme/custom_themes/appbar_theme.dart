import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class AAppbarTheme {
  AAppbarTheme._();

  static const lightappbartheme = AppBarTheme(
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: AColors.textprimary,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AColors.textprimary,
    ),
    actionsIconTheme: IconThemeData(color: AColors.textprimary, size: 24),
    iconTheme: IconThemeData(color: AColors.textprimary, size: 24),
  );

  /// `iconTheme` used to be black here, which hid the drawer and back buttons
  /// against the dark app bar.
  static const darkappbartheme = AppBarTheme(
    centerTitle: false,
    backgroundColor: Colors.transparent,
    foregroundColor: AColors.textPrimaryDark,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AColors.textPrimaryDark,
    ),
    actionsIconTheme: IconThemeData(color: AColors.textPrimaryDark, size: 24),
    iconTheme: IconThemeData(color: AColors.textPrimaryDark, size: 24),
  );
}
