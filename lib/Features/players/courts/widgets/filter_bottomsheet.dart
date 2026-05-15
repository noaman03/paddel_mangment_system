import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/utils/helpers/helper_func.dart';

void showFiltersBottomSheet() {
  bool darkMode = AHelperFunction.isDarkMode(Get.context!);
  final CourtBrowseController controller = Get.find<CourtBrowseController>();

  Get.bottomSheet(
    Container(
      height: AHelperFunction.screenHeight() * 0.8,
      decoration: BoxDecoration(
        color: darkMode ? AColors.dark : AColors.light,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: darkMode ? AColors.grey : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(Get.context!)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: darkMode ? AColors.white : AColors.textprimary,
                      ),
                ),
                Row(
                  children: [
                    // Results counter
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${controller.filteredCourtsCount} results',
                            style: const TextStyle(
                              color: AColors.primaryColor,
                              fontSize: ASizes.fontSizeSm,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        controller.clearAllFilters();
                      },
                      child: Text(
                        'Clear All',
                        style: Theme.of(Get.context!)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: AColors.primaryColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range Filter
                  buildFilterSection(
                    'Price Range',
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: darkMode
                            ? AColors.containerDark
                            : AColors.containerLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: darkMode
                              ? AColors.grey.withOpacity(0.3)
                              : AColors.borderPrimary,
                        ),
                      ),
                      child: Obx(() => Column(
                            children: [
                              RangeSlider(
                                activeColor: AColors.primaryColor,
                                inactiveColor: darkMode
                                    ? AColors.grey.withOpacity(0.3)
                                    : Colors.grey.shade300,
                                values: RangeValues(
                                  controller.filterController.minPrice.value,
                                  controller.filterController.maxPrice.value,
                                ),
                                min: 0,
                                max: 1000,
                                divisions: 50,
                                labels: RangeLabels(
                                  'EGP ${controller.filterController.minPrice.value.round()}',
                                  'EGP ${controller.filterController.maxPrice.value.round()}',
                                ),
                                onChanged: (values) {
                                  controller.updatePriceRange(
                                      values.start, values.end);
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'EGP ${controller.filterController.minPrice.value.round()}',
                                    style: TextStyle(
                                      color: darkMode
                                          ? AColors.white
                                          : AColors.textprimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'EGP ${controller.filterController.maxPrice.value.round()}',
                                    style: TextStyle(
                                      color: darkMode
                                          ? AColors.white
                                          : AColors.textprimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),

                  // Court Type Filter
                  buildFilterSection(
                    'Court Type',
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.filterController.courtTypes
                              .map((type) {
                            final isSelected = controller
                                .filterController.selectedCourtTypes
                                .contains(type);
                            return FilterChip(
                              label: Text(
                                type,
                                style: TextStyle(
                                  color: isSelected
                                      ? AColors.white
                                      : (darkMode
                                          ? AColors.white
                                          : AColors.textprimary),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                controller.toggleCourtType(type);
                              },
                              selectedColor: AColors.primaryColor,
                              backgroundColor: darkMode
                                  ? AColors.containerDark
                                  : AColors.containerLight,
                              checkmarkColor: AColors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AColors.primaryColor
                                    : (darkMode
                                        ? AColors.grey
                                        : AColors.borderPrimary),
                              ),
                            );
                          }).toList(),
                        )),
                  ),

                  // Facilities Filter
                  buildFilterSection(
                    'Facilities',
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.filterController.facilities
                              .map((facility) {
                            final isSelected = controller
                                .filterController.selectedFacilities
                                .contains(facility);
                            return FilterChip(
                              label: Text(
                                facility,
                                style: TextStyle(
                                  color: isSelected
                                      ? AColors.white
                                      : (darkMode
                                          ? AColors.white
                                          : AColors.textprimary),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                controller.toggleFacility(facility);
                              },
                              selectedColor: AColors.primaryColor,
                              backgroundColor: darkMode
                                  ? AColors.containerDark
                                  : AColors.containerLight,
                              checkmarkColor: AColors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AColors.primaryColor
                                    : (darkMode
                                        ? AColors.grey
                                        : AColors.borderPrimary),
                              ),
                            );
                          }).toList(),
                        )),
                  ),

                  // Distance Filter (if location is available)
                  Obx(() => controller
                          .locationController.locationPermissionGranted.value
                      ? buildFilterSection(
                          'Maximum Distance',
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: darkMode
                                  ? AColors.containerDark
                                  : AColors.containerLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: darkMode
                                    ? AColors.grey.withOpacity(0.3)
                                    : AColors.borderPrimary,
                              ),
                            ),
                            child: Obx(() => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Within ${controller.locationController.maxDistance.value.round()} km from your location',
                                      style: TextStyle(
                                        color: darkMode
                                            ? AColors.white
                                            : AColors.textprimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Slider(
                                      value: controller
                                          .locationController.maxDistance.value,
                                      min: 1,
                                      max: 100,
                                      divisions: 99,
                                      activeColor: AColors.primaryColor,
                                      inactiveColor: darkMode
                                          ? AColors.grey.withOpacity(0.3)
                                          : Colors.grey.shade300,
                                      onChanged: (value) {
                                        controller.updateMaxDistance(value);
                                      },
                                    ),
                                  ],
                                )),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primaryColor,
                  foregroundColor: AColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Obx(() => Text(
                      'Show ${controller.filteredCourtsCount} Results',
                      style: const TextStyle(
                        fontSize: ASizes.fontSizeMd,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

// Helper function for filter sections
Widget buildFilterSection(String title, Widget content) {
  final bool darkMode = AHelperFunction.isDarkMode(Get.context!);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: ASizes.fontSizeLg,
          fontWeight: FontWeight.bold,
          color: darkMode ? AColors.white : AColors.textprimary,
        ),
      ),
      const SizedBox(height: ASizes.spaceBtwItems),
      content,
      const SizedBox(height: ASizes.spaceBtwSections),
    ],
  );
}
