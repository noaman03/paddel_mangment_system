import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class AHelperFunction {
  /// Define your product specific colors here and it witt natch the attribute cotors and show specific

  // Maps color names to Flutter Color objects
  static Color? getColor(String value) {
    if (value == "Black") {
      return Colors.black;
    } else if (value == "White") {
      return Colors.white;
    } else if (value == "Red") {
      return Colors.red;
    } else if (value == "Blue") {
      return Colors.blue;
    } else if (value == "Green") {
      return Colors.green;
    } else if (value == "Yellow") {
      return Colors.yellow;
    } else if (value == "Purple") {
      return Colors.purple;
    } else if (value == "Pink") {
      return Colors.pink;
    } else if (value == "Orange") {
      return Colors.orange;
    } else if (value == "Gray") {
      return Colors.grey;
    } else if (value == "Brown") {
      return Colors.brown;
    } else if (value == "Cyan") {
      return Colors.cyan;
    } else if (value == "Teal") {
      return Colors.teal;
    } else if (value == "Indigo") {
      return Colors.indigo;
    } else if (value == "Lime") {
      return Colors.lime;
    } else if (value == "Amber") {
      return Colors.amber;
    } else {
      return null;
    }
  }

  /// Displays a temporary message at the bottom of the screen.
  ///
  /// Routed through [AppFeedback] instead of `ScaffoldMessenger.of(Get.context!)`:
  /// the force-unwrapped context threw whenever this was called before the
  /// first frame or after the navigator was torn down, so the feedback never
  /// reached the user.
  static void showSnackBar(String message) => AppFeedback.info(message);

  // Shows a dialog box with title, message and OK button
  static void showAlert(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Navigates to a new screen using standard navigation
  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // Shortens text to specified length with ellipsis if needed
  static String truncateText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Checks if app is currently in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Fallback used when no context is available yet (a phone-sized viewport),
  /// so a sizing helper can never throw a null-check exception mid-callback.
  static const Size _fallbackScreenSize = Size(390, 844);

  /// Current screen size.
  ///
  /// Pass the local [context] where possible: the value then also responds to
  /// rotation and split-screen. `Get.context` is only the last resort and is
  /// null-checked rather than force-unwrapped.
  static Size screenSize([BuildContext? context]) {
    final ctx = context ?? Get.context;
    if (ctx == null) return _fallbackScreenSize;
    return MediaQuery.of(ctx).size;
  }

  // Gets current device screen width
  static double screenWidth([BuildContext? context]) =>
      screenSize(context).width;

  // Gets current device screen height
  static double screenHeight([BuildContext? context]) =>
      screenSize(context).height;

  // Formats DateTime to specified string format
  static String getFormattedDate(
    DateTime date, {
    String format = 'dd MM yyyy',
  }) {
    return DateFormat(format).format(date);
  }

  // Removes duplicate items from a list
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  // Organizes widgets into rows with specified number per row
  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrapperList = <Widget>[];
    for (int i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(
        i,
        i + rowSize > widgets.length ? widgets.length : i + rowSize,
      );
      wrapperList.add(Row(children: rowChildren));
    }
    return wrapperList;
  }
}
