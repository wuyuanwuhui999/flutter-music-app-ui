// Basic widget smoke test for the music app.
//
// The Flutter counter template test that shipped with this project was not
// applicable (MyApp is not a const constructor and the app has no counter),
// which made `flutter test` / `flutter analyze` fail. This version just makes
// sure the app boots into a MaterialApp without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_music_app/main.dart';

void main() {
  testWidgets('App boots into a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
