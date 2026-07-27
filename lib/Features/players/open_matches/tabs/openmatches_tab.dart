import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/openmatches_creatmatch.dart.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

Widget buildOpenMatchesTab(bool isDark) {
  final controller = Get.find<OpenMatchesController>();
  return Column(
    children: [
      // Filters Row
      Container(
        padding: const EdgeInsets.all(ASizes.paddingMd),
        child: Row(
          children: [
            // Match Type Filter
            Expanded(
              child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ASizes.paddingSm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AColors.grey : AColors.borderPrimary,
                      ),
                      borderRadius:
                          BorderRadius.circular(ASizes.borderRadiusMd),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedMatchType.value,
                        items: controller.matchTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isDark
                                    ? AColors.white
                                    : AColors.textprimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            controller.updateMatchType(value!),
                        dropdownColor: isDark ? AColors.dark : Colors.white,
                      ),
                    ),
                  )),
            ),

            const SizedBox(width: ASizes.spaceBtwItems),

            // Skill Level Filter
            Expanded(
              child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ASizes.paddingSm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AColors.grey : AColors.borderPrimary,
                      ),
                      borderRadius:
                          BorderRadius.circular(ASizes.borderRadiusMd),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedSkillLevel.value,
                        items: controller.skillLevels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(
                              level,
                              style: TextStyle(
                                color: isDark
                                    ? AColors.white
                                    : AColors.textprimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            controller.updateSkillLevel(value!),
                        dropdownColor: isDark ? AColors.dark : Colors.white,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),

      // Matches List
      Expanded(
        child: Obx(() => controller.filteredMatches.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_tennis,
                      size: 64,
                      color: isDark ? AColors.grey : AColors.darkGrey,
                    ),
                    const SizedBox(height: ASizes.spaceBtwItems),
                    Text(
                      'No matches found',
                      style: TextStyle(
                        fontSize: ASizes.fontSizeLg,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AColors.grey : AColors.darkGrey,
                      ),
                    ),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(
                        color: isDark ? AColors.grey : AColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(ASizes.paddingMd),
                itemCount: controller.filteredMatches.length,
                itemBuilder: (context, index) {
                  final match = controller.filteredMatches[index];
                  return buildMatchCard(match, isDark);
                },
              )),
      ),
    ],
  );
}
