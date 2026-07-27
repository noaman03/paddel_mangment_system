import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/controller/area_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/utils/helpers/helper_func.dart';

void showAreasBottomSheet() {
  final CourtBrowseController controller = Get.find<CourtBrowseController>();
  final AreaController areaController = Get.find<AreaController>();

  bool dark = AHelperFunction.isDarkMode(Get.context!);
  Get.bottomSheet(
    Container(
      height: AHelperFunction.screenHeight() * 0.7,
      decoration: BoxDecoration(
        color: dark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Area',
                  style:
                      Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                            color: dark ? Colors.white : Colors.black,
                          ),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearAreaFilter();
                    Get.back();
                  },
                  child: Text(
                    'Clear',
                    style: Theme.of(Get.context!)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: dark ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Area Search
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search areas...',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: areaController.searchAreas,
            ),
          ),

          // Areas List
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: areaController.filteredAreas.length,
                  itemBuilder: (context, index) {
                    final area = areaController.filteredAreas[index];
                    final isSelected =
                        controller.filterController.selectedArea.value ==
                            area['name'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AColors.primaryColor
                            : AColors.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.location_city,
                          color:
                              isSelected ? Colors.white : AColors.primaryColor,
                        ),
                      ),
                      title: Text(
                        area['name'],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('${area['courtCount']} courts available'),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AColors.primaryColor)
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        controller.selectArea(area['name']);
                        Get.back();
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
