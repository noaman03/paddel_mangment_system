import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

class GenderSelection extends StatelessWidget {
  const GenderSelection({
    super.key,
    required this.controller,
  });

  final UserRestController controller;

  @override
  Widget build(BuildContext context) {
    final dark = ADeviceutils.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: ASizes.fontSizeMd,
            color: dark ? AColors.light : AColors.dark,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwInputFields),
        // Wrap gender selection in Obx for reactive updates
        Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.updateSelectedGender('Male');
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: controller.selectedGender.value == 'Male'
                            ? AColors.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.selectedGender.value == 'Male'
                              ? AColors.primaryColor
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            color: controller.selectedGender.value == 'Male'
                                ? Colors.white
                                : AColors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Male',
                            style: TextStyle(
                              color: controller.selectedGender.value == 'Male'
                                  ? AColors.light
                                  : AColors.dark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.updateSelectedGender('Female');
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: controller.selectedGender.value == 'Female'
                            ? AColors.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.selectedGender.value == 'Female'
                              ? AColors.primaryColor
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female,
                            color: controller.selectedGender.value == 'Female'
                                ? AColors.light
                                : AColors.dark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Female',
                            style: TextStyle(
                              color: controller.selectedGender.value == 'Female'
                                  ? AColors.light
                                  : AColors.dark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
