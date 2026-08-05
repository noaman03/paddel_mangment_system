import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_email/useremail_continue.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_email/useremail_footer.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_email/useremail_form.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_email/useremail_header.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/widgets/background_decoration.dart';

class UserEmail extends StatefulWidget {
  const UserEmail({super.key});

  @override
  State<UserEmail> createState() => _UserEmailState();
}

class _UserEmailState extends State<UserEmail> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          // `buildBackgroundDecoration` returns a bare Stack, so the
          // `Positioned.fill` has to live here.
          Positioned.fill(child: buildBackgroundDecoration(c.isDark)),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ASizes.paddingLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(height: ASizes.paddingSm),

                          const SignUpHeader(),
                          const SizedBox(height: ASizes.spaceBtwSections),

                          // Email input
                          UserEmailForm(emailController: emailController),
                          const SizedBox(height: ASizes.spaceBtwSections),

                          // Continue button
                          ContinueEmail(emailController: emailController),
                          const SizedBox(height: ASizes.spaceBtwSections),

                          const SignUpFooter(),
                          const SizedBox(height: ASizes.spaceBtwSections),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
