import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/widgets/filter_bottomsheet.dart';
import 'package:padel_management_system/Features/players/courts/widgets/filter_button.dart';
import 'package:padel_management_system/Features/players/courts/widgets/nearest_filter.dart';
import 'package:padel_management_system/Features/players/courts/widgets/area_bottomsheet.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

Container searchbar(TextEditingController searchController, bool dark) {
  // Access the controller using Get.find
  final CourtBrowseController controller = Get.find<CourtBrowseController>();

  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: searchController,
            style: TextStyle(
              color: dark ? AColors.light : AColors.dark,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: dark ? AColors.containerDark : AColors.containerLight,
              hintText: 'Search courts, areas, or clubs...',
              hintStyle: TextStyle(color: dark ? AColors.light : AColors.dark),
              prefixIcon: Icon(
                Icons.search,
                color: dark ? AColors.light : AColors.dark,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: dark ? AColors.light : AColors.dark,
                      ),
                      onPressed: () {
                        searchController.clear();
                        controller.clearSearch();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: controller.searchCourts,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwItems),

        // Filter Buttons Row - Fixed to use proper controller references
        Obx(() => Row(
              children: [
                // Filters Button
                Expanded(
                  child: buildFilterButton(
                    icon: Icons.tune,
                    label: 'Filters',
                    onPressed: () => showFiltersBottomSheet(),
                    hasActiveFilters: controller
                            .filterController.selectedCourtTypes.isNotEmpty ||
                        controller
                            .filterController.selectedFacilities.isNotEmpty ||
                        controller.filterController.minPrice.value > 0 ||
                        controller.filterController.maxPrice.value < 1000,
                  ),
                ),
                const SizedBox(width: ASizes.spaceBtwInputFields),

                // Areas Button
                Expanded(
                  child: buildFilterButton(
                    icon: Icons.location_on,
                    label: 'Areas',
                    onPressed: showAreasBottomSheet,
                    hasActiveFilters: controller
                        .filterController.selectedArea.value.isNotEmpty,
                  ),
                ),
                const SizedBox(width: ASizes.spaceBtwInputFields),

                // Nearest Button - Fixed condition
                Expanded(
                  child: buildFilterButton(
                    icon: Icons.my_location,
                    label: 'Nearest',
                    onPressed: () => showNearestBottomSheet(),
                    hasActiveFilters:
                        controller.locationController.maxDistance.value <
                            50, // Default is 50km
                  ),
                ),
              ],
            )),
      ],
    ),
  );
}
