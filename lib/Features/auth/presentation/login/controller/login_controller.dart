import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:padelsystem/Screens/home/player_home.dart';
import 'package:padelsystem/Features/owner/dashboard/owner_dashboard.dart';

class LoginController extends GetxController {
  var isObscure = true.obs;
  var rememberMe = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() => isObscure.value = !isObscure.value;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both email and password'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    isLoading.value = true;

    try {
      // Check for owner credentials
      if (emailController.text.toLowerCase() == 'owner' &&
          passwordController.text == 'owner') {
        // Navigate to owner dashboard
        Get.offAll(() => const OwnerDashboard());
        return;
      }

      // Replace with actual login logic for regular players
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success for players
      Get.offAll(() => const PlayerHome());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
