import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padelsystem/Features/auth/presentation/login/widgets/divide_socialbutton.dart';
import 'package:padelsystem/Features/auth/presentation/login/widgets/login_form.dart';
import 'package:padelsystem/Features/auth/presentation/login/widgets/login_header.dart';
import 'package:padelsystem/Features/auth/presentation/login/widgets/signup_link.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/text_strings.dart';
import 'package:padelsystem/core/widgets/background_decoration.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeInOut,
    ));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    fadeController.forward();
    slideController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fadeController.dispose();
    slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: isDark ? AColors.dark : AColors.light,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background decorative elements
          buildBackgroundDecoration(isDark),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(ASizes.defaultSpace),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Top spacing
                              SizedBox(
                                height: isKeyboardVisible
                                    ? ASizes.spaceBtwItems
                                    : ASizes.spaceBtwSections,
                              ),

                              // Logo and welcome section
                              LoginHeader(isCompact: isKeyboardVisible),

                              // Dynamic spacing
                              SizedBox(
                                height: isKeyboardVisible
                                    ? ASizes.spaceBtwItems
                                    : ASizes.spaceBtwSections,
                              ),

                              // Login form
                              LoginFormWidget(
                                emailController: emailController,
                                passwordController: passwordController,
                              ),

                              SizedBox(
                                height: isKeyboardVisible
                                    ? ASizes.spaceBtwItems
                                    : ASizes.spaceBtwSections,
                              ),

                              // OR divider & social login buttons (hide when keyboard is open)
                              if (!isKeyboardVisible) ...[
                                const DividerSocialButtons(),
                                const SizedBox(height: ASizes.spaceBtwItems),
                              ],

                              // Sign up link
                              const SignUpLink(),

                              // Bottom spacing
                              SizedBox(
                                height: isKeyboardVisible
                                    ? ASizes.spaceBtwItems
                                    : ASizes.spaceBtwSections,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
