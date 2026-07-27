import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/widgets/court_list.dart';
import 'package:padel_management_system/Features/players/courts/widgets/filter_bottomsheet.dart';
import 'package:padel_management_system/Features/players/courts/widgets/area_bottomsheet.dart';
import 'package:padel_management_system/Features/players/courts/widgets/nearest_filter.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/helpers/helper_func.dart'; // Add this import

class CourtBrowseScreen extends StatelessWidget {
  const CourtBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        AHelperFunction.isDarkMode(context); // Fixed method call
    final controller = Get.put(CourtBrowseController());

    return Scaffold(
      backgroundColor: isDark ? AColors.dark : AColors.light,
      body: SafeArea(
        child: Column(
          children: [
            // Unified Header
            const PlayerScreenHeader(
              title: 'Courts',
              showNotifications: false,
            ),

            // Content Area
            Expanded(
              child: Obx(() {
                // Loading state - Fixed to use proper controller reference
                if (controller.courtDataController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AColors.primaryColor,
                    ),
                  );
                }

                // Error state - Fixed to use proper controller reference
                if (controller.courtDataController.hasError.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading courts',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? AColors.white : AColors.textprimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.courtDataController.errorMessage.value,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDark ? AColors.grey : AColors.textsecondarry,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.refreshCourts(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AColors.primaryColor,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: AColors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Main content
                return RefreshIndicator(
                  onRefresh: controller.refreshCourts,
                  child: Padding(
                    padding: const EdgeInsets.all(ASizes.paddingMd),
                    child: Column(
                      children: [
                        // Search Bar
                        PlayerSearchBar(
                          hintText: 'Search courts, areas, or clubs...',
                          onChanged: controller.searchCourts,
                        ),

                        const SizedBox(height: ASizes.spaceBtwItems),

                        // Filter Buttons Row - Fixed to use proper controller references
                        Row(
                          children: [
                            // Filters Button
                            Expanded(
                              child: PlayerFilterButton(
                                icon: Icons.tune,
                                label: 'Filters',
                                onPressed: () => showFiltersBottomSheet(),
                                hasActiveFilters: controller.filterController
                                        .selectedCourtTypes.isNotEmpty ||
                                    controller.filterController
                                        .selectedFacilities.isNotEmpty ||
                                    controller.filterController.minPrice.value >
                                        0 ||
                                    controller.filterController.maxPrice.value <
                                        1000,
                              ),
                            ),

                            const SizedBox(width: ASizes.spaceBtwInputFields),

                            // Areas Button
                            Expanded(
                              child: PlayerFilterButton(
                                icon: Icons.location_on,
                                label: 'Areas',
                                onPressed: showAreasBottomSheet,
                                hasActiveFilters: controller.filterController
                                    .selectedArea.value.isNotEmpty,
                              ),
                            ),

                            const SizedBox(width: ASizes.spaceBtwInputFields),

                            // Nearest Button
                            Expanded(
                              child: PlayerFilterButton(
                                icon: Icons.my_location,
                                label: 'Nearest',
                                onPressed: () => showNearestBottomSheet(),
                                hasActiveFilters: controller
                                        .locationController.maxDistance.value <
                                    50,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: ASizes.spaceBtwItems),

                        // Results counter - Fixed to use proper controller references
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${controller.filteredCourtsCount} courts found',
                              style: TextStyle(
                                fontSize: ASizes.fontSizeSm,
                                color: isDark
                                    ? AColors.white
                                    : AColors.textsecondarry,
                              ),
                            ),
                            if (controller.filterController.selectedCourtTypes.isNotEmpty ||
                                controller.filterController.selectedFacilities
                                    .isNotEmpty ||
                                controller.filterController.selectedArea.value
                                    .isNotEmpty ||
                                controller.filterController.minPrice.value >
                                    0 ||
                                controller.filterController.maxPrice.value <
                                    1000)
                              TextButton(
                                onPressed: controller.clearAllFilters,
                                child: const Text(
                                  'Clear all filters',
                                  style: TextStyle(
                                    color: AColors.primaryColor,
                                    fontSize: ASizes.fontSizeSm,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: ASizes.spaceBtwItems),

                        // Courts List
                        Expanded(child: buildCourtsList()),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
