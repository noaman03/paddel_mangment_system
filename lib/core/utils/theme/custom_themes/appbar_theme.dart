import 'package:flutter/material.dart';

class AAppbarTheme {
  AAppbarTheme._();
  static const lightappbartheme = AppBarTheme(
    centerTitle: false,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    actionsIconTheme: IconThemeData(color: Colors.black, size: 24),
    iconTheme: IconThemeData(color: Colors.black, size: 24),
  );
  static const darkappbartheme = AppBarTheme(
    centerTitle: false,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
    iconTheme: IconThemeData(color: Colors.black, size: 24),
  );
}
