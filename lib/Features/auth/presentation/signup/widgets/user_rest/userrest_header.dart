import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

class UserRestHeader extends StatelessWidget {
  const UserRestHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ADeviceutils.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: 0.8,
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
                text: 'Final step!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AColors.primaryColor,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ASizes.sm),
        Text(
          "lets's wrap this up!",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: isDarkMode ? AColors.light : AColors.dark),
        ),
      ],
    );
  }
}
