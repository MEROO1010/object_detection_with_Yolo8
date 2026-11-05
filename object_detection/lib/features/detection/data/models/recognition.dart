import 'dart:ui' show Rect;

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/detected_object.dart';
import 'detection.dart';

/// A [Detection] enriched with its human readable label.
class Recognition {
  const Recognition({
    required this.id,
    required this.label,
    required this.confidence,
    required this.location,
  });

  factory Recognition.fromDetection(int id, Detection detection, List<String> labels) {
    final index = detection.classIndex + AppConstants.labelOffset;
    final label = index >= 0 && index < labels.length ? labels[index] : 'unknown';
    return Recognition(
      id: id,
      label: label,
      confidence: detection.score,
      location: detection.box,
    );
  }

  final int id;
  final String label;
  final double confidence;
  final Rect location;

  DetectedObject toEntity() => DetectedObject(
        id: id,
        label: label,
        confidence: confidence,
        boundingBox: location,
      );
}
