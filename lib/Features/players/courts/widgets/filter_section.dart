import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/core/utils/helpers/helper_func.dart';

Widget buildFilterSection(String title, Widget content) {
  bool darkMode = AHelperFunction.isDarkMode(Get.context!);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: darkMode ? Colors.white : Colors.black,
            ),
      ),
      const SizedBox(height: 12),
      content,
      const SizedBox(height: 24),
    ],
  );
}
