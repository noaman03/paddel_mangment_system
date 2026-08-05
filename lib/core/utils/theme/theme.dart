import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/appbar_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/chip_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/text_field_theme.dart';
import 'package:padel_management_system/core/utils/theme/custom_themes/text_theme.dart';

// ignore: camel_case_types
class appTheme {
  appTheme._();

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AColors.primaryColor,
    // The accent green is light — white on it is 1.91:1, so the M3 "on
    // primary" role has to be the dark ink (7.6:1).
    onPrimary: AColors.ink,
    primaryContainer: Color(0xFFD7F7E9),
    onPrimaryContainer: Color(0xFF04422B),
    secondary: AColors.primaryDeep,
    onSecondary: AColors.white,
    tertiary: AColors.info,
    onTertiary: AColors.white,
    error: AColors.error,
    onError: AColors.white,
    errorContainer: Color(0xFFFBE4E5),
    onErrorContainer: Color(0xFF7A1418),
    surface: AColors.white,
    onSurface: AColors.textprimary,
    surfaceContainerLowest: AColors.white,
    surfaceContainerLow: AColors.lightGrey,
    surfaceContainer: AColors.softGrey,
    surfaceContainerHigh: Color(0xFFE9EDEB),
    surfaceContainerHighest: Color(0xFFE1E7E3),
    onSurfaceVariant: AColors.textsecondarry,
    outline: AColors.borderPrimary,
    outlineVariant: AColors.borderSecondary,
    inverseSurface: AColors.dark,
    onInverseSurface: AColors.textPrimaryDark,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AColors.primaryColor,
    onPrimary: AColors.ink,
    primaryContainer: Color(0xFF0D4C33),
    onPrimaryContainer: Color(0xFFC7F5E1),
    secondary: AColors.primaryLight,
    onSecondary: Color(0xFF06301F),
    tertiary: AColors.info,
    onTertiary: AColors.white,
    error: AColors.error,
    onError: AColors.white,
    errorContainer: Color(0xFF4A1417),
    onErrorContainer: Color(0xFFFFD9DA),
    surface: AColors.containerDark,
    onSurface: AColors.textPrimaryDark,
    surfaceContainerLowest: AColors.dark,
    surfaceContainerLow: Color(0xFF161D1A),
    surfaceContainer: AColors.containerDark,
    surfaceContainerHigh: AColors.containerDarkElevated,
    surfaceContainerHighest: Color(0xFF2A3430),
    onSurfaceVariant: AColors.textSecondaryDark,
    outline: AColors.borderDark,
    outlineVariant: Color(0xFF242E29),
    inverseSurface: AColors.light,
    onInverseSurface: AColors.textprimary,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  static ThemeData lightTheme = _base(
    scheme: _lightScheme,
    textTheme: ATextTheme.lightTextTheme,
    scaffoldBackground: AColors.light,
    surface: AColors.white,
    border: AColors.borderPrimary,
    mutedText: AColors.textsecondarry,
    primaryText: AColors.textprimary,
    appBarTheme: AAppbarTheme.lightappbartheme,
    chipTheme: AChipTheme.lightChipTheme,
    checkboxTheme: ACheckboxtheme.lightCheckboxTheme,
    bottomSheetTheme: ABottomSheetTheme.lightBottomSheetTheme,
    inputTheme: ATextFormFieldTheme.lightInputDecorationTheme,
    elevatedButtonTheme: AElevatedButtonTheme.lightElevatedButtonTheme,
    snackBarBackground: const Color(0xFF1F2A25),
  );

  static ThemeData darkTheme = _base(
    scheme: _darkScheme,
    textTheme: ATextTheme.darkTextTheme,
    scaffoldBackground: AColors.dark,
    surface: AColors.containerDark,
    border: AColors.borderDark,
    mutedText: AColors.textSecondaryDark,
    primaryText: AColors.textPrimaryDark,
    appBarTheme: AAppbarTheme.darkappbartheme,
    chipTheme: AChipTheme.darkChipTheme,
    checkboxTheme: ACheckboxtheme.darkCheckboxTheme,
    bottomSheetTheme: ABottomSheetTheme.darkBottomSheetTheme,
    inputTheme: ATextFormFieldTheme.darkInputDecorationTheme,
    elevatedButtonTheme: AElevatedButtonTheme.darkElevatedButtonTheme,
    snackBarBackground: AColors.containerDarkElevated,
  );

  /// Everything both themes share. Filling these in centrally is what stops
  /// every screen from having to hand-roll `isDark ? ... : ...` for dialogs,
  /// dropdowns, sliders, list tiles and so on.
  static ThemeData _base({
    required ColorScheme scheme,
    required TextTheme textTheme,
    required Color scaffoldBackground,
    required Color surface,
    required Color border,
    required Color mutedText,
    required Color primaryText,
    required AppBarTheme appBarTheme,
    required ChipThemeData chipTheme,
    required CheckboxThemeData checkboxTheme,
    required BottomSheetThemeData bottomSheetTheme,
    required InputDecorationTheme inputTheme,
    required ElevatedButtonThemeData elevatedButtonTheme,
    required Color snackBarBackground,
  }) {
    final bool isDark = scheme.brightness == Brightness.dark;

    // The accent green is only 1.91:1 on white, so brand-coloured *text* has to
    // deepen in light mode. On dark surfaces the accent is already 8.4:1.
    final Color brandText = isDark ? AColors.primaryColor : AColors.primaryInk;

    return ThemeData(
      useMaterial3: true,
      fontFamily: ATextTheme.fontFamily,
      colorScheme: scheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: surface,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: appBarTheme,
      chipTheme: chipTheme,
      checkboxTheme: checkboxTheme,
      bottomSheetTheme: bottomSheetTheme,
      inputDecorationTheme: inputTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      iconTheme: IconThemeData(color: primaryText, size: 22),
      primaryIconTheme: IconThemeData(color: primaryText, size: 22),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: mutedText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        scrimColor: Colors.black.withValues(alpha: isDark ? 0.6 : 0.4),
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: mutedText,
        textColor: primaryText,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AColors.primaryColor,
        unselectedItemColor: mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AColors.white,
        unselectedLabelColor: mutedText,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        inputDecorationTheme: inputTheme,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(surface),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: border),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackBarBackground,
        contentTextStyle: const TextStyle(
          color: AColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: AColors.primaryLight,
        elevation: 6,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AColors.primaryColor,
        inactiveTrackColor: border,
        thumbColor: AColors.primaryColor,
        overlayColor: AColors.primaryColor.withValues(alpha: 0.16),
        valueIndicatorColor: AColors.primaryColor,
        valueIndicatorTextStyle: const TextStyle(
          color: AColors.white,
          fontWeight: FontWeight.w700,
        ),
        trackHeight: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AColors.primaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AColors.white
                : (isDark ? AColors.grey : AColors.white)),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AColors.primaryColor
                : border),
        trackOutlineColor: WidgetStatePropertyAll<Color>(border),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AColors.primaryColor
                : mutedText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandText,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandText,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AColors.primaryDeep,
        foregroundColor: AColors.white,
        elevation: 4,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AColors.primaryColor,
        selectionColor: AColors.primaryColor.withValues(alpha: 0.28),
        selectionHandleColor: AColors.primaryColor,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color:
              isDark ? AColors.containerDarkElevated : const Color(0xFF1F2A25),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: AColors.white, fontSize: 12),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AColors.primaryColor,
        headerForegroundColor: AColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: AColors.primaryColor,
        collapsedIconColor: mutedText,
        textColor: primaryText,
        collapsedTextColor: primaryText,
      ),
    );
  }
}
