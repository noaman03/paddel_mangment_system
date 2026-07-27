import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/continue_data.dart';

class ContinueData extends StatelessWidget {
  ContinueData(
      {super.key,
      required this.emailController,
      required this.firstNameController,
      required this.lastNameController,
      required this.phoneController,
      required this.passwordController,
      required this.confirmPasswordController});

  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final ContinueDataController controller = Get.put(ContinueDataController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.validateAndContinue(
                      context,
                      firstNameController,
                      lastNameController,
                      phoneController,
                      passwordController,
                      confirmPasswordController,
                      emailController.text.trim(),
                    ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ));
  }
}
