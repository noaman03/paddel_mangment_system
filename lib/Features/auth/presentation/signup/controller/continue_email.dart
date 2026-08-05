import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/user_data.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class ContinueEmailController extends GetxController {
  var isLoading = false.obs;

  Future<void> validateAndContinue(
      TextEditingController emailController) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final isValidEmail =
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

      if (!isValidEmail) {
        AppFeedback.error(
          'Check your email',
          email.isEmpty
              ? 'Enter the email address you want to sign up with.'
              : '"$email" is not a valid email address.',
        );
        return;
      }

      // Simulate network delay and then navigate
      await Future.delayed(const Duration(milliseconds: 300));

      Get.to(() => UserData(email: emailController));
    } finally {
      isLoading.value = false;
    }
  }
}
