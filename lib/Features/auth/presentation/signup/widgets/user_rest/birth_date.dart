import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class BirthDate extends StatelessWidget {
  const BirthDate({super.key, required this.controller});

  final UserRestController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: ASizes.fontSizeMd,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwInputFields),

        // The fill, hint and icon colours now come from inputDecorationTheme;
        // hand-rolling them made the hint identical to the typed value.
        Obx(
          () => TextField(
            controller: controller.birthdateController,
            readOnly: true,
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Select your date of birth',
              prefixIcon: const Icon(Icons.calendar_today, size: 20),
              suffixIcon: controller.selectedDate.value == null
                  ? null
                  : IconButton(
                      tooltip: 'Clear date',
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.updateSelectedDate(null),
                    ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
            onTap: () => controller.selectDate(context),
          ),
        ),
      ],
    );
  }
}
