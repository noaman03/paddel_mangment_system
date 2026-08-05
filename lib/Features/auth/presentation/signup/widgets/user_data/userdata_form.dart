import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/continue_data.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/widgets/name_textfield.dart';
import 'package:padel_management_system/core/widgets/password_requirements.dart';

class UserDataForm extends StatelessWidget {
  const UserDataForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    // Registered once by _UserDataState.initState — a Get.put here would have
    // handed the Continue button a different instance.
    final controller = Get.find<ContinueDataController>();

    return Form(
      // The key lives on the controller so the Continue button can trigger the
      // inline errors for fields the user never touched.
      key: controller.formKey,
      child: Column(
        children: [
          // First and last name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NameTextField(
                  controller: firstNameController,
                  hintText: 'First name',
                  validator: controller.validateFirstName,
                ),
              ),
              const SizedBox(width: ASizes.spaceBtwInputFields),
              Expanded(
                child: NameTextField(
                  controller: lastNameController,
                  hintText: 'Last name',
                  validator: controller.validateLastName,
                ),
              ),
            ],
          ),
          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Phone number
          PhoneTextField(
            controller: phoneController,
            validator: controller.validatePhone,
          ),
          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Password + strength meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => PasswordTextField(
                  controller: passwordController,
                  hintText: 'Create password',
                  obscureText: controller.isObscure.value,
                  onToggleVisibility: controller.togglePasswordVisibility,
                  validator: controller.validatePassword,
                  onChanged: controller.updatePassword,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => _PasswordStrengthBar(
                    password: controller.currentPassword.value,
                    strength: controller.passwordStrength,
                  )),
            ],
          ),
          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Confirm password
          Obx(
            () => PasswordTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm password',
              obscureText: controller.isConfirmObscure.value,
              onToggleVisibility: controller.toggleConfirmPasswordVisibility,
              validator: (value) => controller.validateConfirmPassword(
                  value, passwordController.text),
              onChanged: controller.updateConfirmPassword,
              additionalSuffixIcon:
                  controller.currentConfirmPassword.value.isEmpty
                      ? null
                      : Icon(
                          controller.passwordsMatch
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: controller.passwordsMatch
                              ? AColors.success
                              : AColors.error,
                          size: 20,
                        ),
            ),
          ),
          const SizedBox(height: ASizes.spaceBtwItems),

          // Pass the live password so the rules tick off as the user types.
          Obx(
            () => PasswordRequirements(
              password: controller.currentPassword.value,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password, required this.strength});

  final String password;
  final int strength;

  static const List<String> _labels = ['Weak', 'Fair', 'Good', 'Strong'];
  static const List<Color> _tones = [
    AColors.error,
    AColors.warning,
    AColors.info,
    AColors.success,
  ];

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final c = context.padel;
    final tone = _tones[strength];

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: 0, end: (strength + 1) / 4),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                backgroundColor: c.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(tone),
                minHeight: 5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _labels[strength],
          style: TextStyle(
            color: c.onSurfaceAccent(tone),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
