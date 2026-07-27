import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

class OpenMatchSearchBar extends StatelessWidget {
  const OpenMatchSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);
    final controller = Get.find<OpenMatchesController>();
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AColors.containerDark : AColors.containerLight,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? AColors.containerDark : AColors.containerLight,
          hintText: 'Search matches, courts, locations...',
          hintStyle: TextStyle(
            color: isDark ? AColors.grey : AColors.darkGrey,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AColors.grey : AColors.darkGrey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ASizes.paddingMd,
            vertical: ASizes.paddingSm + 4,
          ),
        ),
        style: TextStyle(
          color: isDark ? AColors.white : AColors.darkerGrey,
        ),
        onChanged: controller.searchMatches,
      ),
    );
  }
}
