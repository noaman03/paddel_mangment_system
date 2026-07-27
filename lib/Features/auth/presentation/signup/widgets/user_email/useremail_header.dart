import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.sports_tennis,
              size: 40,
              color: AColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Welcome Text
        Text('Get Started with',
            style: Theme.of(context).textTheme.displayMedium),
        Text(
          'Padelit',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AColors.primaryColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your email to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
