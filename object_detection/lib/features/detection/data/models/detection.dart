import 'dart:ui' show Rect;

/// Raw model output for one object (before label lookup).
class Detection {
  const Detection({
    required this.classIndex,
    required this.score,
    required this.box,
  });

  final int classIndex;
  final double score;

  /// Normalized box (0..1).
  final Rect box;
}
