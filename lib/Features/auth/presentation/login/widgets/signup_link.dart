import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/user_email.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Center(
      child: Padding(
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
            padding: const EdgeInsets.all(ASizes.paddingSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  color: c.brandText,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text.rich(
                      TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(color: c.textSecondary, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: c.brandText,
                              fontWeight: FontWeight.w700,
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
