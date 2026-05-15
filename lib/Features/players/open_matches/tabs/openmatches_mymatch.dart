import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:padelsystem/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padelsystem/Features/players/open_matches/widgets/openmatches_creatmatch.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';

Widget buildMyMatchesTab(bool isDark) {
  final controller = Get.find<OpenMatchesController>();
  return Obx(() => controller.myMatches.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 64,
                color: isDark ? AColors.grey : AColors.darkGrey,
              ),
              const SizedBox(height: ASizes.spaceBtwItems),
              Text(
                'No matches yet',
                style: TextStyle(
                  fontSize: ASizes.fontSizeLg,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AColors.grey : AColors.darkGrey,
                ),
              ),
              Text(
                'Join some matches to see them here',
                style: TextStyle(
                  color: isDark ? AColors.grey : AColors.darkGrey,
                ),
              ),
            ],
          ),
        )
      : ListView.builder(
          padding: const EdgeInsets.all(ASizes.paddingMd),
          itemCount: controller.myMatches.length,
          itemBuilder: (context, index) {
            final match = controller.myMatches[index];
            return buildMyMatchCard(match, isDark);
          },
        ));
}
