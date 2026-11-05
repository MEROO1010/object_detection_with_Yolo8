import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/detection_controller.dart';
import '../state/detection_state.dart';
import '../widgets/camera_preview.dart';
import '../widgets/detection_card.dart';
import '../widgets/detection_overlay.dart';
import '../widgets/statistics_panel.dart';
import '../../../../services/permission_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late final DetectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<DetectionController>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.stop(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Live detection'),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.tune),
              onPressed: () => Navigator.pushNamed(context, Routes.settings),
            ),
          ],
        ),
        body: Consumer<DetectionController>(
          builder: (context, controller, _) {
            final state = controller.state;
            switch (state.status) {
              case DetectionStatus.initial:
              case DetectionStatus.loading:
                return const LoadingView(message: 'Starting camera and model…');
              case DetectionStatus.error:
                return _ErrorView(
                  message: state.errorMessage ?? 'Unexpected error.',
                  onRetry: controller.start,
                );
              case DetectionStatus.detecting:
                final camera = controller.cameraController;
                if (camera == null) return const LoadingView();
                return _DetectionView(camera: camera, state: state);
            }
          },
        ),
      ),
    );
  }
}

class _DetectionView extends StatelessWidget {
  const _DetectionView({required this.camera, required this.state});

  final CameraController camera;
  final DetectionState state;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    return Stack(
      children: [
        Positioned.fill(
          child: LiveCameraPreview(
            controller: camera,
            overlay: DetectionOverlay(objects: state.objects),
          ),
        ),
        if (state.showStatistics)
          Positioned(
            top: topInset,
            left: 12,
            right: 12,
            child: StatisticsPanel(state: state),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: state.objects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => DetectionCard(object: state.objects[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            AppButton(label: 'Try again', icon: Icons.refresh, onPressed: onRetry),
            TextButton(
              onPressed: () => const PermissionService().openSettings(),
              child: const Text('Open app settings'),
            ),
          ],
        ),
      ),
    );
  }
}
