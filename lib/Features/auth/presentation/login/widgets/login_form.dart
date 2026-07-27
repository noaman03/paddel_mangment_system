import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final loginController = Get.put(LoginController());
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(ASizes.paddingLg),
      decoration: BoxDecoration(
        color: isDark ? AColors.containerDark : Colors.white,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Email field
          _buildEnhancedTextField(
            controller: widget.emailController,
            focusNode: _emailFocus,
            nextFocus: _passwordFocus,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),

          const SizedBox(height: ASizes.spaceBtwInputFields + 4),

          // Password field
          Obx(() => _buildEnhancedTextField(
                controller: widget.passwordController,
                focusNode: _passwordFocus,
                hint: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: loginController.isObscure.value,
                onToggleObscure: loginController.togglePasswordVisibility,
                isDark: isDark,
              )),

          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Remember me + Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: loginController.rememberMe.value,
                          onChanged: loginController.toggleRememberMe,
                          activeColor: AColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: isDark ? AColors.grey : AColors.darkGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )),
              TextButton(
                onPressed: () {
                  // Navigate to forgot password screen
                },
                style: TextButton.styleFrom(
                  foregroundColor: AColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: ASizes.spaceBtwSections),

          // Enhanced Login Button
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: loginController.isLoading.value
                        ? AColors.primaryColor.withOpacity(0.7)
                        : AColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: loginController.isLoading.value ? 0 : 8,
                    shadowColor: AColors.primaryColor.withOpacity(0.4),
                  ),
                  onPressed: loginController.isLoading.value
                      ? null
                      : () {
                          loginController.login(
                            context: context,
                            emailController: widget.emailController,
                            passwordController: widget.passwordController,
                          );
                        },
                  child: loginController.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Logging in...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (focusNode.hasFocus)
            BoxShadow(
              color: AColors.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: isObscure,
        onEditingComplete: () {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        style: TextStyle(
          fontSize: 16,
          color: isDark ? AColors.light : AColors.dark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: focusNode.hasFocus
              ? (isDark ? AColors.dark : Colors.white)
              : (isDark ? AColors.containerDark : AColors.containerLight),
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? AColors.light : AColors.dark,
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              icon,
              color: focusNode.hasFocus
                  ? AColors.primaryColor
                  : (isDark ? AColors.light : AColors.dark),
              size: 22,
            ),
          ),
          suffixIcon: isPassword
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      isObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: isDark ? AColors.grey : AColors.darkGrey,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AColors.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
