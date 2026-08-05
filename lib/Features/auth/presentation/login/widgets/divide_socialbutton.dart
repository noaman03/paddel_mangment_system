import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class DividerSocialButtons extends StatelessWidget {
  const DividerSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Column(
      children: [
        // "OR" divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ASizes.paddingLg),
          child: Row(
            children: [
              Expanded(child: _FadingRule(color: c.border)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(child: _FadingRule(color: c.border)),
            ],
          ),
        ),

        // Social login buttons
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: 'assets/icons/google-svgrepo-com.svg',
                label: 'Google',
                onPressed: () => _notAvailable('Google'),
              ),
            ),
            const SizedBox(width: ASizes.spaceBtwItems),
            Expanded(
              child: _SocialButton(
                icon: 'assets/icons/facebook-round-svgrepo-com.svg',
                label: 'Facebook',
                iconColor: const Color(0xFF1877F2),
                onPressed: () => _notAvailable('Facebook'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The offline portfolio build has no OAuth backend, so rather than being a
  /// silent no-op these buttons explain what they would do.
  void _notAvailable(String provider) => AppFeedback.info(
        '$provider sign-in is disabled',
        'This demo runs offline — use one of the demo accounts below the form.',
      );
}

/// A hairline that fades out towards the "OR" pill.
class _FadingRule extends StatelessWidget {
  const _FadingRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, color, Colors.transparent],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor,
  });

  final String icon;
  final String label;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.border, width: 1.5),
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
                  ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
