import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

class UserdataHeader extends StatelessWidget {
  const UserdataHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ADeviceutils.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: 0.5,
          backgroundColor: isDarkMode ? AColors.white : AColors.grey,
          valueColor: const AlwaysStoppedAnimation<Color>(AColors.primaryColor),
          minHeight: 4,
        ),
        const SizedBox(height: ASizes.spaceBtwSections),

        // Title section
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'Tell me more ',
                  style: Theme.of(context).textTheme.headlineLarge),
              TextSpan(
                text: 'about you!',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: AColors.primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwItems),
        Text(
          'Help us by filling in the following details',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwSections),
      ],
    );
  }
}
