import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class UserdataHeader extends StatelessWidget {
  const UserdataHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.5,
            // The track polarity used to be inverted, which painted a hard
            // white band across the top of the dark signup screen.
            backgroundColor:
                c.isDark ? AColors.darkerGrey : AColors.borderPrimary,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AColors.primaryColor),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwSections),

        // Title section
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Tell me more ',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              TextSpan(
                text: 'about you!',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: c.brandText),
              ),
            ],
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwItems),
        Text(
          'Help us by filling in the following details',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: ASizes.spaceBtwSections),
      ],
    );
  }
}
