import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/widgets/court_card.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/helpers/helper_func.dart';

Widget buildCourtsList() {
  final bool dark = AHelperFunction.isDarkMode(Get.context!);
  final CourtBrowseController controller = Get.find<CourtBrowseController>();

  return Obx(() {
    if (controller.courtDataController.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: AColors.primaryColor,
        ),
      );
    }

    if (controller.filteredCourts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis,
              size: 64,
              color: dark ? AColors.grey : Colors.grey,
            ),
            const SizedBox(height: ASizes.spaceBtwItems),
            Text(
              'No courts found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: dark ? AColors.white : AColors.textprimary,
              ),
            ),
            const SizedBox(height: ASizes.spaceBtwItems),
            Text(
              controller.courtDataController.allCourts.isEmpty
                  ? 'No courts available at the moment'
                  : 'Try adjusting your filters or search terms',
              style: TextStyle(
                color: dark ? AColors.grey : AColors.textsecondarry,
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.courtDataController.allCourts.isNotEmpty) ...[
              const SizedBox(height: ASizes.spaceBtwItems),
              ElevatedButton(
                onPressed: controller.clearAllFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primaryColor,
                ),
                child: const Text(
                  'Clear All Filters',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: controller.filteredCourts.length,
      itemBuilder: (context, index) {
        final court = controller.filteredCourts[index];
        return buildCourtCard(court);
      },
    );
  });
}
