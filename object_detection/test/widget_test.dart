import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:object_detection_app/app/app.dart';
import 'package:object_detection_app/features/detection/domain/entities/detected_object.dart';
import 'package:object_detection_app/features/detection/domain/repositories/detection_repository.dart';
import 'package:object_detection_app/features/detection/domain/usecases/detect_objects.dart';
import 'package:object_detection_app/features/detection/presentation/controllers/detection_controller.dart';
import 'package:provider/provider.dart';
import 'package:object_detection_app/services/permission_service.dart';

class _FakeRepository implements DetectionRepository {
  @override
  CameraController? get cameraController => null;
  @override
  Future<void> initialize() async {}
  @override
  Future<Stream<List<DetectedObject>>> startDetection() async => const Stream.empty();
  @override
  Future<void> stopDetection() async {}
  @override
  void setConfidenceThreshold(double value) {}
  @override
  Future<void> release() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  Widget buildApp() {
    final repository = _FakeRepository();
    return ChangeNotifierProvider(
      create: (_) => DetectionController(
        detectObjects: DetectObjects(repository),
        repository: repository,
        permissionService: const PermissionService(),
      ),
      child: const ObjectDetectionApp(),
    );
  }

  testWidgets('home page shows the title and the start button', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.text('Real-time object detection'), findsOneWidget);
    expect(find.text('Start detection'), findsOneWidget);
  });

  testWidgets('settings page exposes the confidence slider', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsOneWidget);
    expect(find.textContaining('Confidence threshold'), findsOneWidget);
  });
}