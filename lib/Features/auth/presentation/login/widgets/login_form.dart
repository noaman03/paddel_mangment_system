import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

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
  void initState() {
    super.initState();
    // Without these listeners the focus-driven glow, border and prefix-icon
    // colour below never repaint — the fields looked completely inert.
    _emailFocus.addListener(_onFocusChanged);
    _passwordFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _passwordFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(ASizes.paddingLg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // Email field
          _buildField(
            controller: widget.emailController,
            focusNode: _emailFocus,
            nextFocus: _passwordFocus,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: ASizes.spaceBtwInputFields + 4),

          // Password field
          Obx(
            () => _buildField(
              controller: widget.passwordController,
              focusNode: _passwordFocus,
              hint: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isObscure: loginController.isObscure.value,
              onToggleObscure: loginController.togglePasswordVisibility,
            ),
          ),

          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Remember me + Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: loginController.rememberMe.value,
                        onChanged: loginController.toggleRememberMe,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showCredentialHelp(context),
                style: TextButton.styleFrom(
                  foregroundColor: c.brandText,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: ASizes.spaceBtwSections),

          // Login button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // The deep brand green, not the accent: this button carries
                  // white text, which is only 1.91:1 on #1DD681.
                  backgroundColor: AColors.primaryDeep,
                  // Kept at full opacity: fading it to 0.7 dropped the white
                  // "Logging in…" label to 2.8:1. The spinner already signals
                  // the disabled state.
                  disabledBackgroundColor: AColors.primaryDeep,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: loginController.isLoading.value ? 0 : 8,
                  shadowColor: AColors.primaryColor.withValues(alpha: 0.4),
                ),
                onPressed: loginController.isLoading.value
                    ? null
                    : () => loginController.login(
                          context: context,
                          emailController: widget.emailController,
                          passwordController: widget.passwordController,
                        ),
                child: loginController.isLoading.value
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Logging in...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, color: Colors.white, size: 20),
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
            ),
          ),
        ],
      ),
    );
  }

  /// The field styling (fill, hint, borders, icon colours) now comes from
  /// `inputDecorationTheme`; only the focus accent is applied locally.
  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    FocusNode? nextFocus,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
  }) {
    final bool focused = focusNode.hasFocus;
    final c = context.padel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (focused)
            BoxShadow(
              color: AColors.primaryColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: isObscure,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
        onEditingComplete: () {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            size: 22,
            color: focused ? c.brandText : null,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  tooltip: isObscure ? 'Show password' : 'Hide password',
                  onPressed: onToggleObscure,
                  icon: Icon(
                    isObscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  /// "Forgot password?" has no backend to talk to in this demo, so instead of
  /// being a dead button it surfaces the credentials that actually work.
  Future<void> _showCredentialHelp(BuildContext context) async {
    final filled = await showDialog<DemoAccount>(
      context: context,
      builder: (dialogContext) {
        final c = dialogContext.padel;
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.key_outlined,
              color: c.brandText,
              size: 24,
            ),
          ),
          title: const Text('Demo credentials', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'This portfolio build has no password-reset backend. Tap an '
                'account to fill the form with credentials that work.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              for (final account in DemoAccounts.all) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(dialogContext, account),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          account.role.icon,
                          size: 18,
                          color: c.onSurfaceAccent(account.role.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.role.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: c.textPrimary,
                                ),
                              ),
                              Text(
                                '${account.email}  ·  ${account.password}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: c.onSurfaceAccent(account.role.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (filled == null) return;
    loginController.fillDemoAccount(
      filled,
      emailController: widget.emailController,
      passwordController: widget.passwordController,
    );
  }
}
