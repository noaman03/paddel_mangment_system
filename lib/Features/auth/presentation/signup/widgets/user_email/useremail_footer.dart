import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/login/login_screen.dart';
import 'package:padel_management_system/Features/auth/presentation/login/widgets/divide_socialbutton.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class SignUpFooter extends StatelessWidget {
  const SignUpFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Column(
      children: [
        const DividerSocialButtons(),
        const SizedBox(height: ASizes.spaceBtwItems),

        // Log-in option
        Center(
          child: TextButton(
            onPressed: () => Get.offAll(() => const LoginScreen()),
            child: Text.rich(
              TextSpan(
                text: 'Already have an account?',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: c.textSecondary),
                children: [
                  TextSpan(
                    text: ' Log in',
                    style: TextStyle(
                      color: c.brandText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwSections),

        // Terms & privacy. Tapping explains that the legal pages are not part
        // of the portfolio build rather than doing nothing at all.
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
            onTap: () => AppFeedback.info(
              'Terms & Privacy',
              'The legal pages are not included in this demo build.',
            ),
            child: Padding(
              padding: const EdgeInsets.all(ASizes.paddingSm),
              child: Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: c.textMuted),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: c.brandText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: c.brandText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
