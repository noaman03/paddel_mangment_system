import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/login/widgets/demo_accounts_card.dart';
import 'package:padel_management_system/Features/auth/presentation/login/widgets/divide_socialbutton.dart';
import 'package:padel_management_system/Features/auth/presentation/login/widgets/login_form.dart';
import 'package:padel_management_system/Features/auth/presentation/login/widgets/login_header.dart';
import 'package:padel_management_system/Features/auth/presentation/login/widgets/signup_link.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/text_strings.dart';
import 'package:padel_management_system/core/controllers/theme_controller.dart';
import 'package:padel_management_system/core/widgets/background_decoration.dart';

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
          // Background decorative elements. The helper returns a bare Stack,
          // so positioning belongs to the caller.
          Positioned.fill(child: buildBackgroundDecoration(isDark)),

          // Appearance toggle — dark mode is otherwise only reachable by
          // changing the operating-system setting.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: const _AppearanceToggle(),
          ),

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

                              // Demo account shortcuts — the reviewer should
                              // never have to guess or type the credentials.
                              if (!isKeyboardVisible) ...[
                                DemoAccountsCard(
                                  emailController: emailController,
                                  passwordController: passwordController,
                                ),
                                const SizedBox(height: ASizes.spaceBtwItems),
                              ],

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

/// Compact System → Light → Dark cycler shown on the login screen.
class _AppearanceToggle extends StatelessWidget {
  const _AppearanceToggle();

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final controller = ThemeController.to;

    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.cycle,
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: c.border),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(controller.icon, size: 16, color: c.brandText),
                const SizedBox(width: 6),
                Text(
                  controller.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
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
