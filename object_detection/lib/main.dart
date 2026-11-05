import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'features/detection/data/datasources/camera_datasource.dart';
import 'features/detection/data/repositories/detection_repository_impl.dart';
import 'features/detection/domain/usecases/detect_objects.dart';
import 'features/detection/presentation/controllers/detection_controller.dart';
import 'services/camera_service.dart';
import 'services/image_preprocessor.dart';
import 'services/permission_service.dart';
import 'services/tflite_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait only: keeps the overlay coordinates aligned with the preview.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final repository = DetectionRepositoryImpl(
    camera: CameraDatasource(CameraService()),
    tflite: TfliteService(),
    preprocessor: const ImagePreprocessor(),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => DetectionController(
        detectObjects: DetectObjects(repository),
        repository: repository,
        permissionService: const PermissionService(),
      ),
      child: const ObjectDetectionApp(),
    ),
  );
}
