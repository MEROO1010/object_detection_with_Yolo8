class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' ($cause)' : ''}';
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([
    super.message = 'Camera permission is required to detect objects.',
  ]);
}

class CameraInitException extends AppException {
  const CameraInitException(super.message, [super.cause]);
}

class ModelLoadException extends AppException {
  const ModelLoadException(super.message, [super.cause]);
}

class InferenceException extends AppException {
  const InferenceException(super.message, [super.cause]);
}
