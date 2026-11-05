import 'dart:async';

import 'package:camera/camera.dart';

import '../../../../services/camera_service.dart';

/// Exposes the camera as a stream of frames.
class CameraDatasource {
  CameraDatasource(this._service);

  final CameraService _service;
  StreamController<CameraImage>? _frames;

  CameraController? get cameraController => _service.controller;
  int get sensorOrientation => _service.sensorOrientation;

  Future<void> initialize() => _service.initialize();

  Future<Stream<CameraImage>> startFrames() async {
    await stopFrames();
    final controller = StreamController<CameraImage>.broadcast();
    _frames = controller;
    await _service.startImageStream((image) {
      if (!controller.isClosed) controller.add(image);
    });
    return controller.stream;
  }

  Future<void> stopFrames() async {
    await _service.stopImageStream();
    await _frames?.close();
    _frames = null;
  }

  Future<void> dispose() async {
    await stopFrames();
    await _service.dispose();
  }
}
