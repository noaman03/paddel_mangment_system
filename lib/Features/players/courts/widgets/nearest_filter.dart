import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/utils/helpers/helper_func.dart';

void showNearestBottomSheet() {
  final CourtBrowseController controller = Get.find<CourtBrowseController>();
  bool dark = AHelperFunction.isDarkMode(Get.context!);

  Get.bottomSheet(
    Container(
      height: AHelperFunction.screenHeight() * 0.5,
      decoration: BoxDecoration(
        color: dark ? AColors.dark : AColors.white,
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
              color: dark ? AColors.grey : Colors.grey.shade300,
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
                  'Nearby Courts',
                  style:
                      Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                            color: dark ? Colors.white : Colors.black,
                          ),
                ),
                TextButton(
                  onPressed: () {
                    controller.updateMaxDistance(50.0); // Reset to default
                    Get.back();
                  },
                  child: Text(
                    'Reset',
                    style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                          color: AColors.primaryColor,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Location Status
          Obx(() => controller
                  .locationController.locationPermissionGranted.value
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AColors.success.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AColors.success),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AColors.success,
                                ),
                              ),
                              Text(
                                controller
                                    .locationController.currentLocation.value,
                                style: TextStyle(
                                  fontSize: ASizes.fontSizeSm,
                                  color: dark
                                      ? AColors.white
                                      : AColors.textprimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AColors.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_off,
                                color: AColors.warning),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Location permission needed to find nearby courts',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              controller.requestLocationPermission();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AColors.primaryColor,
                              foregroundColor: AColors.white,
                            ),
                            child: const Text('Enable Location'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

          // Distance Slider (only show if location is available)
          Obx(() => controller
                  .locationController.locationPermissionGranted.value
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Distance',
                          style: TextStyle(
                            fontSize: ASizes.fontSizeLg,
                            fontWeight: FontWeight.bold,
                            color: dark ? AColors.white : AColors.textprimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() => Column(
                              children: [
                                Text(
                                  'Within ${controller.locationController.maxDistance.value.round()} km',
                                  style: TextStyle(
                                    fontSize: ASizes.fontSizeMd,
                                    fontWeight: FontWeight.w600,
                                    color: AColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Slider(
                                  value: controller
                                      .locationController.maxDistance.value,
                                  min: 1,
                                  max: 100,
                                  divisions: 99,
                                  activeColor: AColors.primaryColor,
                                  inactiveColor: dark
                                      ? AColors.grey.withOpacity(0.3)
                                      : Colors.grey.shade300,
                                  onChanged: (value) {
                                    controller.updateMaxDistance(value);
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('1 km',
                                        style: TextStyle(
                                          color: dark
                                              ? AColors.grey
                                              : AColors.textsecondarry,
                                          fontSize: ASizes.fontSizeSm,
                                        )),
                                    Text('100 km',
                                        style: TextStyle(
                                          color: dark
                                              ? AColors.grey
                                              : AColors.textsecondarry,
                                          fontSize: ASizes.fontSizeSm,
                                        )),
                                  ],
                                ),
                              ],
                            )),
                        const SizedBox(height: 20),
                        Obx(() => Text(
                              '${controller.nearbyCourtsCount} courts found nearby',
                              style: TextStyle(
                                color:
                                    dark ? AColors.white : AColors.textprimary,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primaryColor,
                  foregroundColor: AColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: ASizes.fontSizeMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
