import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/continue_data.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_data/userdata_continue.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_data/userdata_form.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_data/userdata_header.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/widgets/background_decoration.dart';

class UserData extends StatefulWidget {
  final TextEditingController email;

  const UserData({super.key, required this.email});

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Registered once here rather than inside both children's build methods:
    // the form and the Continue button must observe the *same* instance.
    Get.put(ContinueDataController());
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    Get.delete<ContinueDataController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // The helper returns a bare Stack; the fill wrapper belongs here.
          Positioned.fill(child: buildBackgroundDecoration(c.isDark)),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: ASizes.paddingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator + titles
                  const UserdataHeader(),

                  UserDataForm(
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    phoneController: phoneController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                  ),
                  const SizedBox(height: ASizes.spaceBtwSections),

                  ContinueData(
                    emailController: widget.email,
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    phoneController: phoneController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                  ),
                  const SizedBox(height: ASizes.spaceBtwSections),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
