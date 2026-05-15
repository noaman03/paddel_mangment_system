import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/auth/presentation/signup/controller/complete_profile_controller.dart';
import 'package:padelsystem/Features/auth/presentation/signup/user_rest.dart';
import 'package:padelsystem/Screens/home/player_home.dart';
import 'package:padelsystem/Features/auth/data/provider_auth.dart';
import 'package:padelsystem/core/Service/provider/provider_database.dart';

class CompleteProfileButton extends StatelessWidget {
  final DateTime? selectedDate;
  final String selectedGender;
  final List<String> avatarImages;
  final int selectedAvatarIndex;

  /// These callbacks allow you to inject Riverpod or other DI logic
  final Future<UserCredential> Function() signup;
  final String? Function() getUserId;
  final Future<void> Function() createUserData;
  final Future<void> Function() uploadAvatar;
  final VoidCallback onSuccess;

  CompleteProfileButton({
    super.key,
    required this.selectedDate,
    required this.selectedGender,
    required this.avatarImages,
    required this.selectedAvatarIndex,
    required this.signup,
    required this.getUserId,
    required this.createUserData,
    required this.uploadAvatar,
    required this.onSuccess,
  });

  final CompleteProfileController controller =
      Get.put(CompleteProfileController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              // Replace with AColors.primaryColor
            ),
            onPressed: controller.isLoading.value
                ? null
                : () => controller.completeProfile(
                      context: context,
                      selectedDate: selectedDate,
                      selectedGender: selectedGender,
                      avatarImages: avatarImages,
                      selectedAvatarIndex: selectedAvatarIndex,
                      signup: signup,
                      getUserId: getUserId,
                      createUserData: createUserData,
                      uploadAvatar: uploadAvatar,
                      onSuccess: onSuccess,
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
                    'Complete Profile',
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

class CompleteProfileWidget extends StatelessWidget {
  const CompleteProfileWidget({
    super.key,
    required this.selectedDate,
    required this.selectedGender,
    required this.avatarImages,
    required this.selectedAvatarIndex,
    required this.ref,
    required this.widget,
  });

  final DateTime? selectedDate;
  final String selectedGender;
  final List<String> avatarImages;
  final int selectedAvatarIndex;
  final WidgetRef ref;
  final UserRest widget;

  @override
  Widget build(BuildContext context) {
    return CompleteProfileButton(
      selectedDate: selectedDate,
      selectedGender: selectedGender,
      avatarImages: avatarImages,
      selectedAvatarIndex: selectedAvatarIndex,
      signup: () async {
        // Call signup and return a UserCredential to match the expected return type
        await ref.read(authStateProvider.notifier).signup(
              email: widget.email,
              firstName: widget.firstName,
              lastName: widget.lastName,
              password: widget.password,
              confirmPassword: widget.confirmPassword,
              role: widget.role,
              phonenumber: widget.phonenumber,
              birthdate: selectedDate!,
              gender: selectedGender,
            );

        // Return a UserCredential (you might need to adjust this based on your actual implementation)
        return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );
      },
      getUserId: () => FirebaseAuth.instance.currentUser?.uid,
      createUserData: () => ref.read(databaseProvider.notifier).createUser(
            email: widget.email,
            firstName: widget.firstName,
            lastName: widget.lastName,
            role: widget.role,
            phonenumber: widget.phonenumber,
            birthdate: selectedDate!,
            gender: selectedGender,
            collectionname: 'players',
          ),
      uploadAvatar: () => ref.read(firebaseStorageProvider).uploadPlayerAvatar(
            FirebaseAuth.instance.currentUser!.uid,
            avatarImages[selectedAvatarIndex],
          ),
      onSuccess: () {
        // Navigate to home or show success
        Get.to(const PlayerHome());
      },
    );
  }
}
