import 'dart:async';

import 'package:camera/camera.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/image_preprocessor.dart';
import '../../../../services/tflite_service.dart';
import '../../domain/entities/detected_object.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/camera_datasource.dart';
import '../models/recognition.dart';

class DetectionRepositoryImpl implements DetectionRepository {
  DetectionRepositoryImpl({
    required CameraDatasource camera,
    required TfliteService tflite,
    required ImagePreprocessor preprocessor,
  })  : _camera = camera,
        _tflite = tflite,
        _preprocessor = preprocessor;

  static const _tag = 'DetectionRepository';

  final CameraDatasource _camera;
  final TfliteService _tflite;
  final ImagePreprocessor _preprocessor;

  StreamController<List<DetectedObject>>? _out;
  StreamSubscription<CameraImage>? _sub;
  bool _busy = false;
  double _threshold = AppConstants.defaultConfidenceThreshold;

  @override
  CameraController? get cameraController => _camera.cameraController;

  @override
  Future<void> initialize() async {
    await Future.wait([_camera.initialize(), _tflite.load()]);
  }

  @override
  void setConfidenceThreshold(double value) => _threshold = value;

  @override
  Future<Stream<List<DetectedObject>>> startDetection() async {
    await stopDetection();
    final out = StreamController<List<DetectedObject>>.broadcast();
    _out = out;

    final frames = await _camera.startFrames();
    final rotation = _camera.sensorOrientation;

    _sub = frames.listen((frame) {
      // Drop frames while a previous one is still being processed.
      if (_busy || out.isClosed) return;
      _busy = true;
      try {
        final input = _preprocessor.preprocess(frame, rotation: rotation);
        final detections = _tflite.run(input, threshold: _threshold);
        final objects = <DetectedObject>[
          for (var i = 0; i < detections.length; i++)
            Recognition.fromDetection(i, detections[i], _tflite.labels).toEntity(),
        ];
        out.add(objects);
      } catch (e, s) {
        AppLogger.e('Frame processing failed', error: e, stackTrace: s, tag: _tag);
        if (!out.isClosed) out.addError(e, s);
      } finally {
        _busy = false;
      }
    });
    return out.stream;
  }

  @override
  Future<void> stopDetection() async {
    await _sub?.cancel();
    _sub = null;
    await _camera.stopFrames();
    await _out?.close();
    _out = null;
    _busy = false;
  }

  @override
  Future<void> release() async {
    await stopDetection();
    await _camera.dispose();
  }

  @override
  Future<void> dispose() async {
    await release();
    _tflite.dispose();
  }
}
