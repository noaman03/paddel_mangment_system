import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';
import 'package:padelsystem/Features/auth/presentation/login/login_screen.dart';
import 'package:padelsystem/core/utils/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Padel System',
      themeMode: ThemeMode.system,
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
