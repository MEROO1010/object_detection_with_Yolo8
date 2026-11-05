import 'package:camera/camera.dart';

import '../entities/detected_object.dart';

abstract class DetectionRepository {
  /// Live camera controller, available after [initialize].
  CameraController? get cameraController;

  /// Opens the camera and loads the model (idempotent).
  Future<void> initialize();

  /// Starts the camera stream and emits detections for each processed frame.
  Future<Stream<List<DetectedObject>>> startDetection();

  Future<void> stopDetection();

  void setConfidenceThreshold(double value);

  /// Stops detection and releases the camera (the model stays loaded).
  Future<void> release();

  /// Releases every resource.
  Future<void> dispose();
}