import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/main.dart';

void main() {
  testWidgets('configures the Padel Management System title', (tester) async {
    late BuildContext buildContext;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          buildContext = context;
          return const SizedBox.shrink();
        },
      ),
    );

    final app = const MyApp().build(buildContext) as GetMaterialApp;

    expect(app.title, 'Padel Management System');
  });
}
