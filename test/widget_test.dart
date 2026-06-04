import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexthouse_instant/flow/screens/idle_screen.dart';
import 'package:nexthouse_instant/flow/screens/processing_screen.dart';
import 'package:nexthouse_instant/theme/app_theme.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.darkTheme, home: child);

void main() {
  testWidgets('IdleScreen renders logo and CTA, taps fire onStart', (
    WidgetTester tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(_wrap(IdleScreen(onStart: () => tapped++)));

    expect(find.text('TAKE A SELFIE'), findsOneWidget);

    await tester.tap(find.text('TAKE A SELFIE'));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('ProcessingScreen renders bundled spinner and Processing text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const ProcessingScreen(capturedImagePath: null)),
    );

    expect(find.text('Processing'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    // Una rotazione del controller (2s) deve essere priva di eccezioni.
    await tester.pump(const Duration(seconds: 2));
  });
}
