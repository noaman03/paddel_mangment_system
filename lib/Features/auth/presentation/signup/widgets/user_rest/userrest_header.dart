import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class UserRestHeader extends StatelessWidget {
  const UserRestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.8,
            backgroundColor:
                c.isDark ? AColors.darkerGrey : AColors.borderPrimary,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AColors.primaryColor),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwSections),

        // Title section
        Text(
          'Final step!',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: c.brandText,
              ),
        ),
        const SizedBox(height: ASizes.sm),
        Text(
          "Let's wrap this up!",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}
