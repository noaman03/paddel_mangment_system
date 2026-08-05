import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/owner/dashboard/owner_dashboard.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Standalone sign-in for the court-owner panel.
///
/// It now shares its credentials with the rest of the app ([DemoAccounts.owner])
/// and signs the session in, so the dashboard, the drawer and the login screen's
/// demo-account card all agree on who is logged in.
class OwnerLoginScreen extends ConsumerStatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  ConsumerState<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends ConsumerState<OwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const DemoAccount _account = DemoAccounts.owner;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Without this the user who taps through to the owner portal and
        // changes their mind is trapped on every platform but Android.
        leading: canPop
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  ASizes.lg,
                  ASizes.sm,
                  ASizes.lg,
                  ASizes.xl,
                ),
                shrinkWrap: true,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AColors.brandGradient,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AColors.primaryColor
                                    .withValues(alpha: 0.32),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: ASizes.lg),
                        Text(
                          'Court Owner Portal',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage your courts, bookings and tournaments',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ASizes.xl),
                  TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Email or username',
                      hintText: 'owner',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Enter your email or username'
                        : null,
                  ),
                  const SizedBox(height: ASizes.md),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'owner',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Enter your password'
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showPasswordHelp,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: ASizes.sm),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: ASizes.lg),
                  _DemoCredentialsCard(
                    account: _account,
                    onFill: _fillDemoCredentials,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = _account.email;
      _passwordController.text = _account.password;
    });
    AppFeedback.info('Demo credentials filled', 'Tap Sign in to continue.');
  }

  void _showPasswordHelp() {
    AppFeedback.info(
      'Password reset is off in the demo',
      'This build has no backend — use owner / owner to sign in.',
    );
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    if (!_account.matches(email, password)) {
      AppFeedback.error(
        'Those credentials did not work',
        'Use ${_account.email} / ${_account.password} for the owner demo.',
      );
      return;
    }

    setState(() => _isLoading = true);
    // 600ms matches the delay LoginController uses; this used to wait 2s.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    SessionController.to.signIn(_account);
    Get.offAll(() => const OwnerDashboard());
    AppFeedback.success(
      'Welcome back',
      'Signed in as ${_account.displayName}.',
    );
  }
}

class _DemoCredentialsCard extends StatelessWidget {
  const _DemoCredentialsCard({required this.account, required this.onFill});

  final DemoAccount account;
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final tone = account.role.color;

    return Container(
      padding: const EdgeInsets.all(ASizes.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.soft(tone),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  account.role.icon,
                  size: 19,
                  color: c.onSurfaceAccent(tone),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo account',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      account.description,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ASizes.sm + 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${account.email}  /  ${account.password}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                TextButton(onPressed: onFill, child: const Text('Fill')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
