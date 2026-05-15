import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/auth/presentation/signup/user_email.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/const/text_strings.dart';

class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: ASizes.paddingMd,
          vertical: ASizes.paddingSm,
        ),
        child: InkWell(
          onTap: () {
            Get.to(
              () => const UserEmail(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          },
          borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ASizes.paddingSm,
              vertical: ASizes.paddingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_outlined,
                  color: AColors.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text.rich(
                      TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(
                          color: isDark ? AColors.grey : AColors.darkGrey,
                          fontSize: 14,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: AColors.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
