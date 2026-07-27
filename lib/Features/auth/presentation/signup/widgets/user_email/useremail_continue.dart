import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/continue_email.dart';

class ContinueEmail extends StatelessWidget {
  final TextEditingController emailController;

  ContinueEmail({super.key, required this.emailController});

  final ContinueEmailController controller = Get.put(ContinueEmailController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () =>
                    controller.validateAndContinue(context, emailController),
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
