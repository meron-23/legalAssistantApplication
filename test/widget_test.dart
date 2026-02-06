// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meedish_legal/main.dart';

void main() {
  testWidgets('Branding smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap in MaterialApp since MainScaffold needs it
    await tester.pumpWidget(const MaterialApp(home: MainScaffold()));

    // Verify that our app builds with the correct branding.
    // Note: Search for 'Meedish Legal News' which is the default title
    expect(find.text('Meedish Legal News'), findsOneWidget);
  });
}
