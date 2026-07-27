import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_data/userdata_continue.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_data/userdata_form.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_data/userdata_header.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';
import 'package:padel_management_system/core/widgets/background_decoration.dart';

class UserData extends StatefulWidget {
  final TextEditingController email;

  const UserData({super.key, required this.email});

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dark = ADeviceutils.isDarkMode(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: dark ? AColors.light : AColors.dark,
              ),
              onPressed: () => Get.back()),
        ),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(children: [
            // Background decorative elements - Full screen
            Positioned.fill(
              child: buildBackgroundDecoration(dark),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator
                      const UserdataHeader(),

                      // First and Last Name Row
                      UserDataForm(
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        phoneController: phoneController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                      ),
                      const SizedBox(height: ASizes.spaceBtwSections),

                      // Continue Button
                      ContinueData(
                        emailController: widget.email,
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        phoneController: phoneController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
