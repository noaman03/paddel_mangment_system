import 'package:flutter/material.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/text_strings.dart';

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AColors.containerDark : AColors.containerLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? AColors.primaryColor.withOpacity(0.3)
              : AColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AColors.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Password Requirements:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AColors.primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('At least 8 characters'),
          _buildRequirementItem('One uppercase letter (A-Z)'),
          _buildRequirementItem('One lowercase letter (a-z)'),
          _buildRequirementItem('One number (0-9)'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
