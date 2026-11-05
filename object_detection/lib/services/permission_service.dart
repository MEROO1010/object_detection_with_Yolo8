import 'package:permission_handler/permission_handler.dart';

import '../core/utils/permissions.dart';

class PermissionService {
  const PermissionService();

  Future<PermissionStatus> cameraStatus() => Permission.camera.status;

  /// Returns `true` when the camera can be used.
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isUsable;
  }

  Future<bool> openSettings() => openAppSettings();
}
