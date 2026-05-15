import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_rest/avatar_selection.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_rest/birth_date.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_rest/gender_selection.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_rest/userrest_continue.dart';
import 'package:padelsystem/Features/auth/presentation/signup/widgets/user_rest/userrest_header.dart';
import 'package:padelsystem/core/Service/firebase/firebase_storage.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/image_string.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/const/text_strings.dart';
import 'package:padelsystem/core/widgets/background_decoration.dart';

// Add this provider definition at the top of your file, outside any class
final firebaseStorageProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

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
  ConsumerState<UserRest> createState() => _userdataState();
}

class _userdataState extends ConsumerState<UserRest> {
  // Initialize the controller
  final UserRestController controller = Get.put(UserRestController());
  final List<String> avatarImages = [
    AImages.avatar1,
    AImages.avatar2,
    AImages.avatar3,
    AImages.avatar4,
    AImages.avatar5,
  ];

  @override
  Widget build(BuildContext context) {
    final dark = ADeviceutils.isDarkMode(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: dark ? AColors.light : AColors.dark),
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: ASizes.paddingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    const UserRestHeader(),
                    const SizedBox(height: ASizes.spaceBtwSections),

                    // 1. Avatar Selection
                    AvatarSelection(
                        avatarImages: avatarImages, controller: controller),
                    const SizedBox(height: ASizes.spaceBtwSections),

                    // 2. Gender Selection with GetX
                    GenderSelection(controller: controller),
                    const SizedBox(height: ASizes.spaceBtwSections),

                    // 3. Birth Date Field - pass the same controller instance
                    BirthDate(controller: controller),

                    const SizedBox(height: ASizes.spaceBtwSections),

                    // Continue Button - Updated to use GetX values
                    Obx(() => CompleteProfileWidget(
                          selectedDate: controller.selectedDate.value,
                          selectedGender: controller.selectedGender.value,
                          avatarImages: avatarImages,
                          selectedAvatarIndex:
                              controller.selectedAvatarIndex.value,
                          ref: ref,
                          widget: widget,
                        )),
                  ],
                ),
              ),
            ),
          ])),
    );
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    Get.delete<UserRestController>();
    super.dispose();
  }
}
