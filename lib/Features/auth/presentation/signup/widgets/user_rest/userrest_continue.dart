import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/data/provider_auth.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/complete_profile_controller.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padel_management_system/core/Service/firebase/firebase_storage.dart';
import 'package:padel_management_system/core/Service/provider/provider_database.dart';

/// Storage service used by the (flag-guarded) remote signup path.
final firebaseStorageProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

/// Everything step 1 and 2 collected, handed to the final step.
@immutable
class SignUpDraft {
  const SignUpDraft({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.confirmPassword,
    required this.phonenumber,
    this.role = 'player',
  });

  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String confirmPassword;
  final int phonenumber;
  final String role;
}

/// The "Complete Profile" call to action of the final signup step.
///
/// This is a [StatefulWidget] on purpose: the previous version registered its
/// GetX controller in a field initializer of a `StatelessWidget` that lived
/// inside an `Obx`, so every avatar/gender tap replaced the controller, reset
/// `isLoading` and re-enabled the button mid-submit.
class CompleteProfileWidget extends StatefulWidget {
  const CompleteProfileWidget({
    super.key,
    required this.controller,
    required this.avatarImages,
    required this.draft,
    required this.ref,
  });

  final UserRestController controller;
  final List<String> avatarImages;
  final SignUpDraft draft;
  final WidgetRef ref;

  @override
  State<CompleteProfileWidget> createState() => _CompleteProfileWidgetState();
}

class _CompleteProfileWidgetState extends State<CompleteProfileWidget> {
  late final CompleteProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.isRegistered<CompleteProfileController>()
        ? Get.find<CompleteProfileController>()
        : Get.put(CompleteProfileController());
  }

  @override
  void dispose() {
    Get.delete<CompleteProfileController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() {
        final loading = profileController.isLoading.value;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed: loading ? null : _submit,
          child: loading
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
        );
      }),
    );
  }

  Future<void> _submit() {
    final restController = widget.controller;
    final avatarIndex = restController.selectedAvatarIndex.value;
    final avatarAsset = avatarIndex < widget.avatarImages.length
        ? widget.avatarImages[avatarIndex]
        : null;

    return profileController.completeProfile(
      selectedDate: restController.selectedDate.value,
      selectedGender: restController.selectedGender.value,
      email: widget.draft.email,
      firstName: widget.draft.firstName,
      lastName: widget.draft.lastName,
      avatarAsset: avatarAsset,
      remoteSignup: _remoteSignup,
    );
  }

  /// Only invoked when [CompleteProfileController.kUseFirebase] is on.
  Future<void> _remoteSignup() async {
    final draft = widget.draft;
    final restController = widget.controller;
    final birthdate = restController.selectedDate.value!;
    final gender = restController.selectedGender.value;

    await widget.ref.read(authStateProvider.notifier).signup(
          email: draft.email,
          firstName: draft.firstName,
          lastName: draft.lastName,
          password: draft.password,
          confirmPassword: draft.confirmPassword,
          role: draft.role,
          phonenumber: draft.phonenumber,
          birthdate: birthdate,
          gender: gender,
        );

    await widget.ref.read(databaseProvider.notifier).createUser(
          email: draft.email,
          firstName: draft.firstName,
          lastName: draft.lastName,
          role: draft.role,
          phonenumber: draft.phonenumber,
          birthdate: birthdate,
          gender: gender,
          collectionname: 'players',
        );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final avatarIndex = restController.selectedAvatarIndex.value;
    if (uid != null && avatarIndex < widget.avatarImages.length) {
      await widget.ref
          .read(firebaseStorageProvider)
          .uploadPlayerAvatar(uid, widget.avatarImages[avatarIndex]);
    }
  }
}
