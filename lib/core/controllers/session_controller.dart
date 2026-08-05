import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';

/// Who is currently signed in.
///
/// Previously every screen hardcoded "Ahmed Hassan" / "ahmed@email.com" and the
/// drawer had no idea which role was active, so signing in as the admin or the
/// owner still rendered a player profile. Screens now read this instead.
class SessionController extends GetxController {
  /// Self-registering so widget tests (and hot reload) can build any screen
  /// without going through `main()`.
  static SessionController get to => Get.isRegistered<SessionController>()
      ? Get.find<SessionController>()
      : Get.put(SessionController(), permanent: true);

  final Rxn<DemoAccount> account = Rxn<DemoAccount>();

  DemoAccount? get current => account.value;

  bool get isSignedIn => account.value != null;

  AppRole get role => account.value?.role ?? AppRole.player;

  String get displayName => account.value?.displayName ?? 'Guest';

  String get email => account.value?.email ?? '';

  void signIn(DemoAccount value) => account.value = value;

  void signOut() => account.value = null;
}
