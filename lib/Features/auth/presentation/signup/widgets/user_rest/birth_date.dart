import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/const/text_strings.dart';

class BirthDate extends StatelessWidget {
  const BirthDate({
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
          'Date of Birth',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: dark ? AColors.light : AColors.dark,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwInputFields),

        // Date picker field with GetX reactive updates
        Obx(() => TextField(
              controller: controller.birthdateController,
              readOnly: true,
              style: TextStyle(
                  fontSize: 16, color: dark ? AColors.light : AColors.dark),
              decoration: InputDecoration(
                hintText: 'Select your date of birth',
                hintStyle:
                    TextStyle(color: dark ? AColors.light : AColors.dark),
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: dark ? AColors.light : AColors.dark,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AColors.primaryColor,
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor:
                    dark ? AColors.containerDark : AColors.containerLight,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                // Show selected date or placeholder
                suffixIcon: controller.selectedDate.value != null
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: dark ? AColors.light : AColors.dark,
                        ),
                        onPressed: () {
                          controller.updateSelectedDate(null);
                        },
                      )
                    : null,
              ),
              onTap: () => controller.selectDate(context),
            )),
      ],
    );
  }
}
