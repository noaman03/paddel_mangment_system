import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/Features/auth/presentation/login/login_screen.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/controllers/theme_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/utils/theme/theme.dart';
import 'package:padel_management_system/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The demo build runs fully offline; a missing/unreachable Firebase project
  // must not stop the app from starting.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase unavailable, continuing in offline demo mode: $e');
  }

  // Both are self-registering, but eager construction keeps startup ordering
  // explicit.
  ThemeController.to;
  SessionController.to;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Padelit — Padel Booking System',
        scaffoldMessengerKey: AppFeedback.messengerKey,
        themeMode: themeController.themeMode.value,
        theme: appTheme.lightTheme,
        darkTheme: appTheme.darkTheme,
        home: _initialHome,
      ),
    );
  }

  /// `?demo=player|admin|owner` deep-links straight into a panel, which keeps
  /// the web demo and the screenshot tooling reproducible.
  ///
  /// Resolved once at startup rather than inside `build`: it signs a session
  /// in, and writing to an Rx during build would re-run on every rebuild and
  /// bounce the user back into the panel they just signed out of.
  static final Widget _initialHome = _resolveInitialHome();

  static Widget _resolveInitialHome() {
    final demo = kIsWeb ? Uri.base.queryParameters['demo'] : null;
    final account = switch (demo) {
      'admin' => DemoAccounts.admin,
      'player' => DemoAccounts.player,
      'owner' => DemoAccounts.owner,
      _ => null,
    };
    if (account == null) return const LoginScreen();

    SessionController.to.signIn(account);
    return LoginController.homeForRole(account.role);
  }
}
