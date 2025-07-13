// Basic widget test for SweetHogs medical dashboard app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:sweethogs_capstone_frontend/main.dart';
import 'package:sweethogs_capstone_frontend/app/controllers/auth_controller.dart';

void main() {
  setUp(() async {
    // Initialize GetStorage for tests
    GetStorage.init();

    // Initialize AuthController
    Get.put(AuthController());
  });

  testWidgets('App should start and show login screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that we're on the login screen
    // Check for login form elements
    expect(find.text('Login'), findsWidgets);
    expect(find.byType(TextFormField), findsWidgets);
  });

  tearDown(() {
    // Reset GetX state after each test
    Get.reset();
  });
}
