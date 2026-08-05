import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Screens/home/player_home.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Finishes the three-step signup.
///
/// The portfolio build ships without a reachable backend. The old flow awaited
/// four live Firebase calls (create user, sign in, Firestore write, Storage
/// upload) and therefore hung for a minute before failing — leaving the user
/// stranded on step 3 with no way into the app. Registration is now completed
/// locally; the Firebase path is kept behind [kUseFirebase] so the code still
/// reads as production-capable.
class CompleteProfileController extends GetxController {
  /// Flip to `true` (and point `firebase_options.dart` at a live project) to
  /// register against Firebase instead of the local demo store.
  static const bool kUseFirebase = false;

  final RxBool isLoading = false.obs;

  Future<void> completeProfile({
    required DateTime? selectedDate,
    required String selectedGender,
    required String email,
    required String firstName,
    required String lastName,
    String? avatarAsset,
    Future<void> Function()? remoteSignup,
  }) async {
    // Guards a double submit: the button is rebuilt whenever the avatar or
    // gender changes, so a second tap could otherwise slip through.
    if (isLoading.value) return;

    if (selectedDate == null) {
      AppFeedback.warning(
        'Birth date required',
        'Tap the date field and pick your date of birth to continue.',
      );
      return;
    }

    isLoading.value = true;
    try {
      if (kUseFirebase && remoteSignup != null) {
        try {
          await remoteSignup();
        } catch (e) {
          // Never strand the user on a backend that is not there.
          AppFeedback.warning(
            'Working offline',
            'The server could not be reached, so your profile was saved on this device.',
          );
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      final displayName = '$firstName $lastName'.trim();
      SessionController.to.signIn(
        DemoAccount(
          role: AppRole.player,
          email: email,
          password: '',
          displayName: displayName.isEmpty ? 'New Player' : displayName,
          description: '$selectedGender player · joined today',
          avatarAsset: avatarAsset,
        ),
      );
    } finally {
      isLoading.value = false;
    }

    AppFeedback.success(
      'Welcome to Padelit, $firstName!',
      'Your player profile is ready — go book a court.',
    );
    // `offAll` (not `to`) so the system back button cannot walk the freshly
    // registered user back into "Final step!".
    Get.offAll(() => const PlayerHome());
  }
}
