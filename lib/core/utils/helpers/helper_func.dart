import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  // Displays temporary message at bottom of screen
  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

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
  static String TruncateText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
  }

  // Checks if app is currently in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Gets current device screen dimensions
  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  // Gets current device screen width
  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  // Gets current device screen height
  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

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
