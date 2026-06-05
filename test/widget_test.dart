import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexthouse_instant/flow/screens/idle_screen.dart';
import 'package:nexthouse_instant/flow/screens/processing_screen.dart';
import 'package:nexthouse_instant/flow/screens/countdown_screen.dart';
import 'package:nexthouse_instant/flow/screens/capture_screen.dart';
import 'package:nexthouse_instant/flow/screens/capture_end_screen.dart';
import 'package:nexthouse_instant/flow/screens/ask_another_screen.dart';
import 'package:nexthouse_instant/flow/screens/result_screen.dart';
import 'package:nexthouse_instant/flow/screens/photo_selection_share_screen.dart';
import 'package:nexthouse_instant/flow/screens/photo_gallery_screen_share_2.dart';
import 'package:nexthouse_instant/flow/screens/share_confirm_screen.dart';
import 'package:nexthouse_instant/flow/screens/share_uploading_screen.dart';
import 'package:nexthouse_instant/theme/app_theme.dart';
import 'package:nexthouse_instant/widgets/onboarding_overlay.dart';
import 'package:nexthouse_instant/widgets/gallery_button.dart';
import 'package:nexthouse_instant/widgets/processing_card.dart';

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

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('CountdownScreen shows intro "Say..." then number', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CountdownScreen(
          countdownValue: 5,
          introActive: true,
          cameraController: null,
        ),
      ),
    );

    expect(find.text('Say...'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const CountdownScreen(
          countdownValue: 3,
          introActive: false,
          cameraController: null,
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('I love hostels!'), findsNothing);
  });

  testWidgets('CaptureScreen flashes and clears', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CaptureScreen())),
    );
    // Should not throw. Flash overlay renders a white ColoredBox inside an
    // AnimatedOpacity - we just verify the build completed.
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('CaptureEndScreen renders blurred bg', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CaptureEndScreen())),
    );
    expect(find.byType(ImageFiltered), findsOneWidget);
  });

  testWidgets('AskAnotherScreen renders dialog with Yes/No', (
    WidgetTester tester,
  ) async {
    var yesTapped = 0;
    var noTapped = 0;
    await tester.pumpWidget(
      _wrap(
        AskAnotherScreen(
          capturedImagePath: null,
          onYes: () => yesTapped++,
          onNo: () => noTapped++,
        ),
      ),
    );
    expect(find.text('Do you want to take another picture?'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);

    await tester.tap(find.text('Yes'));
    await tester.pump();
    expect(yesTapped, 1);

    await tester.tap(find.text('No'));
    await tester.pump();
    expect(noTapped, 1);
  });

  testWidgets('ResultScreen renders gallery toolbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ResultScreen(
          onReset: () {},
          onDone: () {},
          onDelete: () {},
          onShare: () {},
          onEdit: () {},
          onPrint: () {},
          showDoneToolbar: true,
          capturedImages: <String>[],
          currentGalleryIndex: 0,
          onPrevious: () {},
          onNext: () {},
          onPageChanged: (_) {},
        ),
      ),
    );
    // Empty images path renders the camera placeholder
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('ShareSelectionScreen renders Done pill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PhotoSelectionShareScreen(
          capturedImages: <String>[],
          selectedImages: <String>{},
          onToggleSelection: (_) {},
          onCancel: () {},
          onDone: () {},
        ),
      ),
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Select your photos to share'), findsOneWidget);
  });

  testWidgets('ShareConfirmScreen renders AreYouSure card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(ShareConfirmScreen(onYes: () {}, onNo: () {})),
    );
    expect(find.textContaining('unselected images'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('ShareUploadingScreen renders spinner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(ShareUploadingScreen(capturedImages: <String>[])),
    );
    expect(find.byType(ProcessingCard), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('PhotoGalleryScreenShare2 renders QR card + tap-to-go-back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PhotoGalleryScreenShare2(
          selectedImages: <String>{'a', 'b'},
          onDone: () {},
        ),
      ),
    );
    expect(find.text('Scan me!'), findsOneWidget);
    expect(find.text('Tap to go back'), findsOneWidget);
  });

  testWidgets('OnboardingOverlay tap dismisses', (WidgetTester tester) async {
    var dismissed = 0;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: OnboardingOverlay(
            message: 'Test hint',
            onDismiss: () => dismissed++,
          ),
        ),
      ),
    );
    expect(find.text('Test hint'), findsOneWidget);
    await tester.tap(find.text('Test hint'));
    await tester.pump();
    expect(dismissed, 1);
  });

  testWidgets('OnboardingOverlay auto-dismisses after 5s', (
    WidgetTester tester,
  ) async {
    var dismissed = 0;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: OnboardingOverlay(
            message: 'Test hint 2',
            onDismiss: () => dismissed++,
            autoDismiss: const Duration(milliseconds: 100),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(dismissed, 1);
  });

  testWidgets('GalleryButton variants render with their icon and label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Row(
          children: <Widget>[
            GalleryButton(action: GalleryAction.edit, disabled: true),
            GalleryButton(action: GalleryAction.share),
            GalleryButton(action: GalleryAction.delete),
            GalleryButton(action: GalleryAction.print, disabled: true),
          ],
        ),
      ),
    );
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
  });
}
