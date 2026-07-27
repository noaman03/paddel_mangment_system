import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/openmatc_colors.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/openmatch_buildformfield.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/openmatch_dropdownfiled.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

Widget buildCreateMatchTab(bool isDark) {
  final controller = Get.find<OpenMatchesController>();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(ASizes.paddingMd),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create New Match',
          style: TextStyle(
            fontSize: ASizes.fontSizeLg,
            fontWeight: FontWeight.bold,
            color: isDark ? AColors.white : AColors.textprimary,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwSections),

        // Match Title
        buildFormField(
          label: 'Match Title',
          hint: 'e.g., Evening Doubles Match',
          isDark: isDark,
        ),

        // Description
        buildFormField(
          label: 'Description',
          hint: 'Describe your match and what you\'re looking for',
          isDark: isDark,
          maxLines: 3,
        ),

        // Court Selection
        buildFormField(
          label: 'Court',
          hint: 'Select or search for a court',
          isDark: isDark,
          suffixIcon: Icons.location_on,
        ),

        // Date & Time
        Row(
          children: [
            Expanded(
              child: buildFormField(
                label: 'Date',
                hint: 'Select date',
                isDark: isDark,
                suffixIcon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: ASizes.spaceBtwItems),
            Expanded(
              child: buildFormField(
                label: 'Time',
                hint: 'Select time',
                isDark: isDark,
                suffixIcon: Icons.access_time,
              ),
            ),
          ],
        ),

        // Players Needed
        buildFormField(
          label: 'Players Needed',
          hint: '1-3 players',
          isDark: isDark,
          keyboardType: TextInputType.number,
        ),

        // Skill Level
        buildDropdownField(
          label: 'Skill Level',
          value: 'Intermediate',
          items: controller.skillLevels.skip(1).toList(), // Skip 'All'
          isDark: isDark,
        ),

        // Match Type
        buildDropdownField(
          label: 'Match Type',
          value: 'Doubles',
          items: controller.matchTypes.skip(1).toList(), // Skip 'All'
          isDark: isDark,
        ),

        const SizedBox(height: ASizes.spaceBtwSections),

        // Create Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: createMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: ASizes.paddingMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
              ),
            ),
            child: const Text(
              'Create Match',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: ASizes.fontSizeMd,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
