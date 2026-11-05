import 'dart:ui' show Rect;

/// A recognized object in the current frame.
/// [boundingBox] is normalized (0..1) relative to the upright camera image.
class DetectedObject {
  const DetectedObject({
    required this.id,
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });

  final int id;
  final String label;
  final double confidence;
  final Rect boundingBox;

  int get confidencePercent => (confidence * 100).round();

  @override
  String toString() => 'DetectedObject($label, $confidencePercent%)';
}
