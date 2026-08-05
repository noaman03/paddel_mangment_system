import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/continue_email.dart';

class ContinueEmail extends StatefulWidget {
  const ContinueEmail({super.key, required this.emailController});

  final TextEditingController emailController;

  @override
  State<ContinueEmail> createState() => _ContinueEmailState();
}

class _ContinueEmailState extends State<ContinueEmail> {
  late final ContinueEmailController controller;

  @override
  void initState() {
    super.initState();
    // Registered here, not in build(): a Get.put in build() re-runs on every
    // rebuild.
    controller = Get.put(ContinueEmailController());
  }

  @override
  void dispose() {
    Get.delete<ContinueEmailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.validateAndContinue(widget.emailController),
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
      ),
    );
  }
}
