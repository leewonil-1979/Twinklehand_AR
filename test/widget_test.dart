// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('TwinkleHand AR Test')),
      ),
    ));

    // Verify that our test widget is displayed
    expect(find.text('TwinkleHand AR Test'), findsOneWidget);
  });
}
