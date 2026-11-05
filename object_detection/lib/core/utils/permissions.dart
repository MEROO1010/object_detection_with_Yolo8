import 'package:permission_handler/permission_handler.dart';

extension PermissionStatusX on PermissionStatus {
  bool get isUsable => isGranted || isLimited;
}

class PermissionMessages {
  PermissionMessages._();

  static String camera(PermissionStatus status) => status.isPermanentlyDenied
      ? 'Camera access is blocked. Enable it from the app settings.'
      : 'Camera permission is required to detect objects.';
}
