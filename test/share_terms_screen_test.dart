import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexthouse_instant/flow/screens/share_terms_screen.dart';
import 'package:nexthouse_instant/flow/photobooth_flow_state.dart';
import 'package:nexthouse_instant/l10n/app_localizations.dart';

void main() {
  testWidgets('ShareTermsScreen renders and triggers callbacks', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool accepted = false;
    bool declined = false;
    final flowState = PhotoboothFlowState();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ShareTermsScreen(
          lastCapturedImagePath: null,
          onAccept: () {
            accepted = true;
          },
          onDecline: () {
            declined = true;
          },
          flowState: flowState,
        ),
      ),
    );

    // Verify Title and Text are in English
    expect(find.text('Cloud Storage & Privacy'), findsOneWidget);
    expect(
      find.textContaining('automatically and permanently deleted upon session expiration'),
      findsOneWidget,
    );

    // Verify Buttons are in English
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);

    // Tap Decline
    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();
    expect(declined, isTrue);

    // Tap Accept
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(accepted, isTrue);
  });
}
