import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/const/text_strings.dart';

class DividerSocialButtons extends StatelessWidget {
  const DividerSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Column(
      children: [
        // Enhanced OR divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ASizes.paddingLg),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark
                            ? AColors.grey.withOpacity(0.5)
                            : Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark ? AColors.containerDark : AColors.containerLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AColors.grey.withOpacity(0.3)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: isDark ? AColors.grey : AColors.darkGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark
                            ? AColors.grey.withOpacity(0.5)
                            : Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Enhanced social login buttons
        Row(
          children: [
            // Google login button
            Expanded(
              child: _buildSocialButton(
                context: context,
                icon: 'assets/icons/google-svgrepo-com.svg',
                label: 'Google',
                onPressed: () {
                  // Add Google Sign In
                },
                isDark: isDark,
              ),
            ),
            const SizedBox(width: ASizes.spaceBtwItems),
            // Facebook login button
            Expanded(
              child: _buildSocialButton(
                context: context,
                icon: 'assets/icons/facebook-round-svgrepo-com.svg',
                label: 'Facebook',
                iconColor: const Color(0xFF1877F2),
                onPressed: () {
                  // Add Facebook Sign In
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
    Color? iconColor,
  }) {
    return Container(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? AColors.containerDark : Colors.white,
          side: BorderSide(
            color:
                isDark ? AColors.grey.withOpacity(0.3) : Colors.grey.shade200,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: 22,
              width: 22,
              colorFilter: iconColor != null
                  ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AColors.white : AColors.textprimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
