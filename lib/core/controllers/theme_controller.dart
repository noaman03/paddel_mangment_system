import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controls light / dark / system appearance.
///
/// The app used to be hard-wired to `ThemeMode.system`, so the only way to see
/// dark mode was to change the OS setting. An in-app toggle is exposed from the
/// player drawer, the admin panel and the owner dashboard.
class ThemeController extends GetxController {
  /// Self-registering so widget tests (and hot reload) can build any screen
  /// without going through `main()`.
  static ThemeController get to => Get.isRegistered<ThemeController>()
      ? Get.find<ThemeController>()
      : Get.put(ThemeController(), permanent: true);

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  bool isDark(BuildContext context) {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  void setMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  /// Flips between explicit light and dark, resolving `system` first.
  void toggle(BuildContext context) =>
      setMode(isDark(context) ? ThemeMode.light : ThemeMode.dark);

  String get label {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  /// Cycles System → Light → Dark → System, for a single-tap app-bar control.
  void cycle() {
    switch (themeMode.value) {
      case ThemeMode.system:
        setMode(ThemeMode.light);
      case ThemeMode.light:
        setMode(ThemeMode.dark);
      case ThemeMode.dark:
        setMode(ThemeMode.system);
    }
  }
}
