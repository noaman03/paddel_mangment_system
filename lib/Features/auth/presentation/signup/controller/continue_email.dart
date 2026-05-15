import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/auth/presentation/signup/user_data.dart';

class ContinueEmailController extends GetxController {
  var isLoading = false.obs;

  void validateAndContinue(
      BuildContext context, TextEditingController emailController) async {
    isLoading.value = true;

    final email = emailController.text.trim();
    final isValidEmail =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    if (!isValidEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      isLoading.value = false;
      return;
    }

    // Simulate network delay and then navigate
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading.value = false;

    Get.to(() => UserData(email: emailController));
  }
}
