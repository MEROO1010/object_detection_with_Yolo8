import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/loading_view.dart';

/// Camera preview with an optional overlay drawn on top of the exact same area.
class LiveCameraPreview extends StatelessWidget {
  const LiveCameraPreview({super.key, required this.controller, this.overlay});

  final CameraController controller;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const LoadingView();
    }
    return Center(child: CameraPreview(controller, child: overlay));
  }
}
