import 'package:flutter/material.dart';

class AColors {
  AColors._();

  //app basic colors
  static const Color primaryColor = Color(0xFF1DD681);
  static const Color secondaryColor = Color(0xFFFFe24b);
  static const Color accentColor = Color(0xFFb0c7ff);
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF1DD681, // Same as primaryColor
    <int, Color>{
      50: Color(0xFFE4F9F0),
      100: Color(0xFFBCF0D9),
      200: Color(0xFF90E7C0),
      300: Color(0xFF64DDA7),
      400: Color(0xFF42D694),
      500: Color(0xFF1DD681), // Primary color
      600: Color(0xFF1AC277),
      700: Color(0xFF15AC6A),
      800: Color(0xFF11975E),
      900: Color(0xFF0A7445),
    },
  );

  //text colors
  static const Color textprimary = Color(0xFF333333);
  static const Color textsecondarry = Color(0xFF6c757D);
  static const Color textwhite = Colors.white;

  //background colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);

  //background container colors
  static const Color containerLight = Color(0xFFF6F6F6);
  static Color containerDark = Colors.white.withOpacity(0.1);

  //button colors
  static const Color buttonPrimary = Color(0xFF1a3cee);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  //border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  //natural shades
  static const Color black = Color(0xFF000000);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);

  //gradient colors
  static Gradient lineargradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFFAD0C4)],
  );
}
