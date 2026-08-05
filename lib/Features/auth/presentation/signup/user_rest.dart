import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_rest/avatar_selection.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_rest/birth_date.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_rest/gender_selection.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_rest/userrest_continue.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/widgets/user_rest/userrest_header.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/image_string.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/widgets/background_decoration.dart';

class UserRest extends ConsumerStatefulWidget {
  final String email;
  final String role = "player";
  final String firstName;
  final String lastName;
  final String password;
  final String confirmPassword;
  final int phonenumber;

  const UserRest({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.confirmPassword,
    required this.phonenumber,
  });

  @override
  ConsumerState<UserRest> createState() => _UserRestState();
}

class _UserRestState extends ConsumerState<UserRest> {
  late final UserRestController controller;

  final List<String> avatarImages = const [
    AImages.avatar1,
    AImages.avatar2,
    AImages.avatar3,
    AImages.avatar4,
    AImages.avatar5,
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserRestController());
  }

  @override
  void dispose() {
    Get.delete<UserRestController>();
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
            // This step used to be a fixed Column with no scroll view, so it
            // overflowed (yellow stripes, unreachable button) on shorter phones.
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: ASizes.paddingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UserRestHeader(),
                  const SizedBox(height: ASizes.spaceBtwSections),

                  // 1. Avatar
                  AvatarSelection(
                    avatarImages: avatarImages,
                    controller: controller,
                  ),
                  const SizedBox(height: ASizes.spaceBtwSections),

                  // 2. Gender
                  GenderSelection(controller: controller),
                  const SizedBox(height: ASizes.spaceBtwSections),

                  // 3. Birth date
                  BirthDate(controller: controller),
                  const SizedBox(height: ASizes.spaceBtwSections),

                  // The button reads the controller through its own Obx, so it
                  // no longer needs an ancestor Obx rebuilding it (which used
                  // to re-register its GetX controller on every tap).
                  CompleteProfileWidget(
                    controller: controller,
                    avatarImages: avatarImages,
                    draft: SignUpDraft(
                      email: widget.email,
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      password: widget.password,
                      confirmPassword: widget.confirmPassword,
                      phonenumber: widget.phonenumber,
                      role: widget.role,
                    ),
                    ref: ref,
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
