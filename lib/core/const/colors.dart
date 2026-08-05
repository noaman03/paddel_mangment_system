import 'package:flutter/material.dart';

/// Central colour palette.
///
/// The historical `AColors.*` names are all preserved so existing screens keep
/// compiling, but the *values* are now tuned so the common
/// `isDark ? AColors.x : AColors.y` pattern produces a readable, high-contrast
/// result in both themes. New code should prefer the semantic
/// `context.padel.*` tokens from [PadelPalette] below.
class AColors {
  AColors._();

  // App brand.
  //
  // Contrast rules, because #1DD681 is a *light* green (relative luminance
  // 0.50) and white text on it is only 1.91:1:
  //   * [primaryColor] is an ACCENT — icons, borders, progress, and text on
  //     dark surfaces (8.4:1 on the dark card). On light surfaces use
  //     [primaryInk] instead.
  //   * Any FILLED brand surface that carries white text uses [primaryDeep]
  //     (4.55:1) or [brandGradient], whose lightest stop is [primaryDeep].
  //   * For an arbitrary fill, ask [foregroundOn].
  static const Color primaryColor = Color(0xFF1DD681);

  /// Filled brand surfaces that carry white text — buttons, gradients, badges.
  static const Color primaryDeep = Color(0xFF0A8757);

  /// The brand colour, dark enough to use as TEXT on a light surface.
  static const Color primaryInk = Color(0xFF0A7445);

  static const Color primaryDark = Color(0xFF08915E);
  static const Color primaryLight = Color(0xFF29E68F);

  /// Near-black used as a foreground on light fills (the vivid green, amber…).
  static const Color ink = Color(0xFF0B1712);
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

  /// Brand gradient used by headers, hero banners and active tabs.
  ///
  /// Deliberately deeper than the accent green: these surfaces carry white
  /// text, and the previous #29E68F top stop rendered it at 1.64:1.
  static const List<Color> brandGradient = <Color>[
    primaryDeep,
    Color(0xFF086F48),
    Color(0xFF05563A),
  ];

  //text colors
  static const Color textprimary = Color(0xFF1A211D);
  static const Color textsecondarry = Color(0xFF5F6B65);
  static const Color textwhite = Colors.white;

  /// Dark-theme text colours.
  static const Color textPrimaryDark = Color(0xFFF2F5F3);
  static const Color textSecondaryDark = Color(0xFFA9B4AE);

  //background colors
  /// Dark theme scaffold background. A near-black with a faint green cast —
  /// pure `Colors.black` made every card and divider disappear.
  static const Color dark = Color(0xFF101613);
  static const Color light = Color(0xFFF4F7F5);

  //background container colors
  static const Color containerLight = Color(0xFFFFFFFF);

  /// Elevated surface in dark mode. This used to be
  /// `Colors.white.withOpacity(0.1)`, which rendered cards as an almost
  /// invisible haze over the black scaffold. It is now opaque.
  static const Color containerDark = Color(0xFF1B2320);

  /// A second, slightly lighter dark surface for nested containers.
  static const Color containerDarkElevated = Color(0xFF232C28);

  //button colors
  static const Color buttonPrimary = Color(0xFF1DD681);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  //border colors
  static const Color borderPrimary = Color(0xFFE1E7E3);
  static const Color borderSecondary = Color(0xFFEFF3F1);
  static const Color borderDark = Color(0xFF2E3A35);

  // Error and validation colors
  static const Color error = Color(0xFFE5484D);
  static const Color success = Color(0xFF30A46C);
  static const Color warning = Color(0xFFF5A524);
  static const Color info = Color(0xFF3E8FF0);

  //natural shades
  static const Color black = Color(0xFF000000);
  static const Color darkerGrey = Color(0xFF3F4A45);
  static const Color darkGrey = Color(0xFF6B7772);

  /// Muted foreground used on dark surfaces (secondary text, icons, borders).
  static const Color grey = Color(0xFFA9B4AE);
  static const Color softGrey = Color(0xFFEFF2F0);
  static const Color lightGrey = Color(0xFFF8FAF9);
  static const Color white = Color(0xFFFFFFFF);

  //gradient colors
  static const Gradient lineargradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: brandGradient,
  );

  /// WCAG relative-contrast ratio between two opaque colours.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// A readable foreground for anything painted on [fill].
  ///
  /// Use this instead of hardcoding `Colors.white` on a coloured surface —
  /// white is only 1.91:1 on the brand green and 2.04:1 on the warning amber.
  static Color foregroundOn(Color fill) =>
      contrast(white, fill) >= contrast(ink, fill) ? white : ink;
}

/// Semantic, brightness-aware colour tokens.
///
/// Prefer these over hand-written `isDark ? a : b` ternaries:
///
/// ```dart
/// final c = context.padel;
/// Container(color: c.surface, child: Text('hi', style: TextStyle(color: c.textPrimary)));
/// ```
class PadelPalette {
  const PadelPalette._(this.isDark);

  final bool isDark;

  /// Page background.
  Color get background => isDark ? AColors.dark : AColors.light;

  /// Card / sheet / dialog background.
  Color get surface => isDark ? AColors.containerDark : AColors.white;

  /// A surface sitting on top of [surface] (nested chips, inner panels).
  Color get surfaceElevated =>
      isDark ? AColors.containerDarkElevated : AColors.softGrey;

  /// Subtle tinted fill, e.g. input backgrounds.
  Color get fill => isDark ? AColors.containerDarkElevated : AColors.lightGrey;

  Color get textPrimary =>
      isDark ? AColors.textPrimaryDark : AColors.textprimary;

  Color get textSecondary =>
      isDark ? AColors.textSecondaryDark : AColors.textsecondarry;

  /// Low-emphasis text (timestamps, captions).
  Color get textMuted => isDark
      ? AColors.textSecondaryDark.withValues(alpha: 0.75)
      : AColors.darkGrey;

  Color get border => isDark ? AColors.borderDark : AColors.borderPrimary;

  Color get divider => isDark
      ? AColors.borderDark.withValues(alpha: 0.8)
      : AColors.borderSecondary;

  Color get shadow => Colors.black.withValues(alpha: isDark ? 0.35 : 0.07);

  Color get primary => AColors.primaryColor;

  /// The brand colour as TEXT on [surface]. The vivid accent green is only
  /// 1.91:1 on white, so light mode uses the deeper ink instead.
  Color get brandText => isDark ? AColors.primaryColor : AColors.primaryInk;

  /// Filled brand surface that carries white text.
  Color get brandFill => AColors.primaryDeep;

  /// Primary tinted background for badges / soft buttons.
  Color get primarySoft =>
      AColors.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12);

  Color get success => AColors.success;
  Color get warning => AColors.warning;
  Color get error => AColors.error;
  Color get info => AColors.info;

  /// Soft tinted background for a status colour, readable in both themes.
  Color soft(Color color) => color.withValues(alpha: isDark ? 0.22 : 0.12);

  /// A status colour adjusted until it is legible as *text* on [surface].
  ///
  /// Lightens toward white on dark and darkens toward black on light, stopping
  /// as soon as the WCAG ratio clears [minRatio]. A fixed lerp could not do
  /// this: the warning amber needs far more correction on a white card than
  /// the info blue does.
  Color onSurfaceAccent(Color color, {double minRatio = 4.5}) {
    final Color target = isDark ? Colors.white : Colors.black;
    Color candidate = color;
    for (var step = 0; step <= 20; step++) {
      candidate = Color.lerp(color, target, step * 0.05)!;
      if (AColors.contrast(candidate, surface) >= minRatio) break;
    }
    return candidate;
  }

  /// A readable foreground for text/icons painted on [fill].
  Color foregroundOn(Color fill) => AColors.foregroundOn(fill);
}

extension PadelPaletteX on BuildContext {
  /// Brightness-aware semantic colours for this build context.
  PadelPalette get padel =>
      PadelPalette._(Theme.of(this).brightness == Brightness.dark);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
