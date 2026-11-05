import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/permission_service.dart';
import '../../domain/entities/detected_object.dart';
import '../../domain/repositories/detection_repository.dart';
import '../../domain/usecases/detect_objects.dart';
import '../state/detection_state.dart';

class DetectionController extends ChangeNotifier {
  DetectionController({
    required DetectObjects detectObjects,
    required DetectionRepository repository,
    required PermissionService permissionService,
  })  : _detectObjects = detectObjects,
        _repository = repository,
        _permissionService = permissionService;

  static const _tag = 'DetectionController';

  final DetectObjects _detectObjects;
  final DetectionRepository _repository;
  final PermissionService _permissionService;

  DetectionState _state = const DetectionState();
  StreamSubscription<List<DetectedObject>>? _sub;
  DateTime? _lastFrameAt;
  int _generation = 0;
  bool _disposed = false;

  DetectionState get state => _state;
  CameraController? get cameraController => _repository.cameraController;

  Future<void> start() async {
    if (_state.status == DetectionStatus.loading || _state.isDetecting) return;
    final generation = ++_generation;
    _emit(_state.copyWith(status: DetectionStatus.loading, clearError: true));

    try {
      if (!await _permissionService.requestCamera()) {
        throw const PermissionDeniedException();
      }
      await _repository.initialize();
      if (generation != _generation) {
        await _repository.release();
        return;
      }
      _repository.setConfidenceThreshold(_state.confidenceThreshold);

      final stream = await _detectObjects();
      if (generation != _generation) {
        await _repository.release();
        return;
      }
      _sub = stream.listen(_onResult, onError: _fail);
      _emit(_state.copyWith(status: DetectionStatus.detecting));
    } catch (e, s) {
      if (generation == _generation) _fail(e, s);
    }
  }

  /// Stops detection and releases the camera.
  /// Pass `notify: false` when called from a widget's `dispose`.
  Future<void> stop({bool notify = true}) async {
    _generation++;
    _lastFrameAt = null;
    final next = _state.copyWith(
      status: DetectionStatus.initial,
      objects: const [],
      fps: 0,
    );
    if (notify) {
      _emit(next);
    } else {
      _state = next;
    }
    await _sub?.cancel();
    _sub = null;
    await _repository.release();
  }

  void setConfidenceThreshold(double value) {
    _repository.setConfidenceThreshold(value);
    _emit(_state.copyWith(confidenceThreshold: value));
  }

  void setShowStatistics(bool value) => _emit(_state.copyWith(showStatistics: value));

  void _onResult(List<DetectedObject> objects) {
    final now = DateTime.now();
    var fps = _state.fps;
    final last = _lastFrameAt;
    if (last != null) {
      final micros = now.difference(last).inMicroseconds;
      if (micros > 0) {
        final instant = 1e6 / micros;
        fps = fps == 0 ? instant : fps * 0.8 + instant * 0.2; // smoothed
      }
    }
    _lastFrameAt = now;
    _emit(_state.copyWith(objects: objects, fps: fps));
  }

  void _fail(Object error, StackTrace stackTrace) {
    AppLogger.e('Detection failed', error: error, stackTrace: stackTrace, tag: _tag);
    final message = error is AppException
        ? error.message
        : 'Something went wrong. Please try again.';
    _sub?.cancel();
    _sub = null;
    _emit(_state.copyWith(status: DetectionStatus.error, errorMessage: message));
    _repository.release();
  }

  void _emit(DetectionState state) {
    _state = state;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
