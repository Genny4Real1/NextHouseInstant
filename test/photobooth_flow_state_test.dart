import 'package:flutter_test/flutter_test.dart';
import 'package:nexthouse_instant/flow/photobooth_flow_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhotoboothFlowState Tests', () {
    test('initial state should be idle', () {
      final flowState = PhotoboothFlowState();
      expect(flowState.state, PhotoboothState.idle);
    });

    test('startFlow should change state to countdown', () {
      final flowState = PhotoboothFlowState();
      flowState.startFlow();
      expect(flowState.state, PhotoboothState.countdown);
    });

    test('startShareFlow should transition state to shareTerms', () {
      final flowState = PhotoboothFlowState();
      flowState.startShareFlow();
      expect(flowState.state, PhotoboothState.shareTerms);
    });

    test('acceptTermsAndProceed should transition state to shareSelection', () {
      final flowState = PhotoboothFlowState();
      flowState.startShareFlow();
      expect(flowState.state, PhotoboothState.shareTerms);

      flowState.acceptTermsAndProceed();
      expect(flowState.state, PhotoboothState.shareSelection);
    });

    test('declineTerms should transition state to result', () {
      final flowState = PhotoboothFlowState();
      flowState.startShareFlow();
      expect(flowState.state, PhotoboothState.shareTerms);

      flowState.declineTerms();
      expect(flowState.state, PhotoboothState.result);
    });

    test('watermark on non-existent or invalid file should return input path gracefully', () async {
      final flowState = PhotoboothFlowState();
      final nonExistentResult = await flowState.applyWatermarkToImageFileTest('/non/existent/path.png');
      expect(nonExistentResult, '/non/existent/path.png');
    });

    test('initial locale should be English', () {
      final flowState = PhotoboothFlowState();
      expect(flowState.localeCode, 'en');
    });

    test('changing locale should update localeCode and notify listeners', () {
      final flowState = PhotoboothFlowState();
      bool listenerNotified = false;
      flowState.addListener(() {
        listenerNotified = true;
      });
      flowState.setLocale('it');
      expect(flowState.localeCode, 'it');
      expect(listenerNotified, true);
    });

    test('resetToHome should reset locale to English', () {
      final flowState = PhotoboothFlowState();
      flowState.setLocale('it');
      expect(flowState.localeCode, 'it');
      
      flowState.resetToHome();
      expect(flowState.localeCode, 'en');
    });

    test('startCountdown should decrement down to 0 and trigger capture at 0', () async {
      final flowState = PhotoboothFlowState();
      flowState.startFlow();
      expect(flowState.state, PhotoboothState.countdown);

      flowState.startCountdown();
      expect(flowState.isCountingDown, isTrue);
      expect(flowState.countdownValue, 5);

      // Advance time by 5 seconds (1 second per tick)
      for (int i = 4; i >= 0; i--) {
        await Future.delayed(const Duration(seconds: 1));
        expect(flowState.countdownValue, i);
      }

      // After countdown reaches 0, capture is triggered and state changes to captureFeedback
      expect(flowState.countdownValue, 0);
      expect(flowState.state, PhotoboothState.captureFeedback);
      expect(flowState.isCountingDown, isFalse);
    });
  });
}
