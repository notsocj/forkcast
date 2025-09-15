// This is a basic Flutter widget test for ForkCast app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:forkcast/main.dart';
import 'package:forkcast/core/constants.dart';

void main() {
  testWidgets('ForkCast app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ForkCastApp());

    // Verify that we have the splash screen with FORKCAST text.
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appDescription), findsOneWidget);
    
    // Wait for all animations and timers to complete
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
