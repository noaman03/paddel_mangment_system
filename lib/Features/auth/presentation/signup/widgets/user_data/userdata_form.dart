import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/auth/presentation/signup/controller/continue_data.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/widgets/name_textfield.dart';
import 'package:padelsystem/core/widgets/password_requirements.dart';

class UserDataForm extends StatelessWidget {
  UserDataForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final controller = Get.put(ContinueDataController());
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First Name and Last Name Row
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

          // Phone Number Field
          PhoneTextField(
            controller: phoneController,
            validator: controller.validatePhone,
          ),
          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Password Field with Strength Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => PasswordTextField(
                    controller: passwordController,
                    hintText: 'Create password',
                    obscureText: controller.isObscure.value,
                    onToggleVisibility: controller.togglePasswordVisibility,
                    validator: controller.validatePassword,
                    onChanged: controller.updatePassword,
                  )),
              const SizedBox(height: 8),
              Obx(() => buildPasswordStrengthIndicator()),
            ],
          ),
          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Confirm Password Field
          Obx(() => PasswordTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm password',
                obscureText: controller.isConfirmObscure.value,
                onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                validator: (value) => controller.validateConfirmPassword(
                    value, passwordController.text),
                onChanged: controller.updateConfirmPassword,
                additionalSuffixIcon:
                    controller.currentConfirmPassword.value.isNotEmpty
                        ? Icon(
                            controller.passwordsMatch
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: controller.passwordsMatch
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          )
                        : null,
              )),
          const SizedBox(height: ASizes.spaceBtwItems),

          // Password Requirements
          const PasswordRequirements(),
        ],
      ),
    );
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Widget buildPasswordStrengthIndicator() {
    final strength = controller.passwordStrength;
    final strengthText = ['Weak', 'Fair', 'Good', 'Strong'];
    final strengthColors = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green
    ];

    if (controller.currentPassword.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (strength + 1) / 4,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(strengthColors[strength]),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strengthText[strength],
                style: TextStyle(
                  color: strengthColors[strength],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
