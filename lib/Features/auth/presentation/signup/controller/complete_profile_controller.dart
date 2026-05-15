import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteProfileController extends GetxController {
  var isLoading = false.obs;

  Future<void> completeProfile({
    required BuildContext context,
    required DateTime? selectedDate,
    required String selectedGender,
    required List<String> avatarImages,
    required int selectedAvatarIndex,
    required Future<UserCredential> Function() signup,
    required String? Function() getUserId,
    required Future<void> Function() createUserData,
    required Future<void> Function() uploadAvatar,
    required VoidCallback onSuccess,
  }) async {
    isLoading.value = true;

    try {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your birth date.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        isLoading.value = false;
        return;
      }

      // Step 1: Signup
      try {
        await signup();

        final userId = getUserId();
        if (userId == null) {
          throw Exception('User ID not available after registration');
        }

        // Step 2: Store user data
        await createUserData();

        // Step 3: Upload avatar
        await uploadAvatar();

        onSuccess();
      } catch (e) {
        String errorMessage = e.toString();

        if (errorMessage.contains('email-already-in-use') ||
            errorMessage.contains('alreadyInUse')) {
          errorMessage = 'This email address is already registered.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Log In',
                textColor: Colors.white,
                onPressed: () {
                  // Go to login
                  Get.toNamed('/login'); // Or use Get.to(LoginScreen());
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        throw e;
      }
    } catch (e) {
      debugPrint('Error in registration process: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
