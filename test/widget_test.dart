// This is a basic Flutter widget test for the Social App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialapp/app.dart';

void main() {
  testWidgets('Social App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that our app loads and shows some expected widgets
    // Since the app shows auth page initially, we should find login/register related text
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
