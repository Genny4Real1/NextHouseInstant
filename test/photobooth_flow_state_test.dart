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
  });
}
