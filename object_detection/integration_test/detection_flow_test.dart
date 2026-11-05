import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart' as app;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:object_detection_app/features/detection/presentation/pages/camera_page.dart';



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tapping "Start detection" opens the camera page', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Start detection'), findsOneWidget);
    await tester.tap(find.text('Start detection'));
    // The camera keeps animating, so pump for a fixed duration instead of settling.
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(CameraPage), findsOneWidget);
  });
}
