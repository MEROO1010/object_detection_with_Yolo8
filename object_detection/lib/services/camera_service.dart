import 'dart:io' show Platform;

import 'package:camera/camera.dart';

import '../core/errors/app_exception.dart';

class CameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  bool get isInitialized => _controller?.value.isInitialized ?? false;

  int get sensorOrientation => _controller?.description.sensorOrientation ?? 0;

  Future<void> initialize() async {
    if (isInitialized) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const CameraInitException('No camera was found on this device.');
      }
      final description = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );
      _controller = controller;
      await controller.initialize();
    } on CameraInitException {
      rethrow;
    } catch (e) {
      await dispose();
      throw CameraInitException('Could not start the camera.', e);
    }
  }

  Future<void> startImageStream(void Function(CameraImage image) onFrame) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const CameraInitException('Camera is not initialized.');
    }
    if (controller.value.isStreamingImages) return;
    await controller.startImageStream(onFrame);
  }

  Future<void> stopImageStream() async {
    final controller = _controller;
    if (controller != null && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
  }

  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      await controller.dispose();
    }
  }
}