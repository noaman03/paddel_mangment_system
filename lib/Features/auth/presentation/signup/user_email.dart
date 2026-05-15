import 'package:flutter/material.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_email/useremail_continue.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_email/useremail_footer.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_email/useremail_form.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_email/useremail_header.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/const/text_strings.dart';
import 'package:padelsystem/core/widgets/background_decoration.dart';

class UserEmail extends StatefulWidget {
  const UserEmail({super.key});

  @override
  State<UserEmail> createState() => _UserEmailState();
}

class _UserEmailState extends State<UserEmail> {
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ADeviceutils.isDarkMode(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AColors.dark : AColors.light,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // Background decorative elements - Full screen
            Positioned.fill(
              child: buildBackgroundDecoration(isDark),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        // App Logo or Icon
                        const SignUpHeader(),

                        const SizedBox(height: ASizes.spaceBtwSections),
                        // Email Input
                        UserEmailForm(emailController: emailController),
                        const SizedBox(height: ASizes.spaceBtwSections),
                        // Continue Button
                        ContinueEmail(emailController: emailController),
                        const SizedBox(height: ASizes.spaceBtwSections),

                        const SignUpFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
