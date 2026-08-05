import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/admin/admin_screen.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/owner/dashboard/owner_dashboard.dart';
import 'package:padel_management_system/Screens/home/player_home.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class LoginController extends GetxController {
  var isObscure = true.obs;
  var rememberMe = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() => isObscure.value = !isObscure.value;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  /// Fills the form with a demo account so the reviewer can sign in with one
  /// tap instead of typing `AMZ 123 mh` by hand.
  void fillDemoAccount(
    DemoAccount account, {
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    emailController.text = account.email;
    passwordController.text = account.password;
  }

  Future<void> login({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppFeedback.warning(
        'Missing details',
        'Enter both an email and a password to continue.',
      );
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final account = DemoAccounts.authenticate(email, password);

      // Wrong credentials used to silently sign the user in as a player.
      if (account == null) {
        final known = DemoAccounts.byEmail(email);
        AppFeedback.error(
          known == null ? 'Account not found' : 'Incorrect password',
          known == null
              ? 'Use one of the demo accounts listed below the form.'
              : 'That password does not match the ${known.role.label} demo account.',
        );
        return;
      }

      SessionController.to.signIn(account);
      AppFeedback.success(
        'Welcome back, ${account.displayName}',
        'Signed in as ${account.role.label}.',
      );
      Get.offAll(() => homeForRole(account.role));
    } finally {
      isLoading.value = false;
    }
  }

  /// Single source of truth for role → landing screen. The owner shortcut used
  /// to land on the admin panel, which is what made the two logins feel mixed
  /// up.
  static Widget homeForRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return const AdminScreen();
      case AppRole.owner:
        return const OwnerDashboard();
      case AppRole.player:
        return const PlayerHome();
    }
  }
}
