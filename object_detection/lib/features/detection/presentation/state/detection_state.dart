import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/detected_object.dart';

enum DetectionStatus { initial, loading, detecting, error }

class DetectionState {
  const DetectionState({
    this.status = DetectionStatus.initial,
    this.objects = const [],
    this.fps = 0,
    this.confidenceThreshold = AppConstants.defaultConfidenceThreshold,
    this.showStatistics = true,
    this.errorMessage,
  });

  final DetectionStatus status;
  final List<DetectedObject> objects;
  final double fps;
  final double confidenceThreshold;
  final bool showStatistics;
  final String? errorMessage;

  bool get isDetecting => status == DetectionStatus.detecting;

  /// Number of detected objects per label, e.g. {person: 2, cup: 1}.
  Map<String, int> get countsByLabel {
    final counts = <String, int>{};
    for (final o in objects) {
      counts[o.label] = (counts[o.label] ?? 0) + 1;
    }
    return counts;
  }

  DetectionState copyWith({
    DetectionStatus? status,
    List<DetectedObject>? objects,
    double? fps,
    double? confidenceThreshold,
    bool? showStatistics,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DetectionState(
      status: status ?? this.status,
      objects: objects ?? this.objects,
      fps: fps ?? this.fps,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      showStatistics: showStatistics ?? this.showStatistics,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}