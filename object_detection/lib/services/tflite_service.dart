import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/asset_constants.dart';
import '../core/errors/app_exception.dart';
import '../features/detection/data/models/detection.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String> _labels = const [];

  List<String> get labels => _labels;
  bool get isLoaded => _interpreter != null;

  Future<void> load() async {
    if (isLoaded) return;
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(AssetConstants.model, options: options);
      final raw = await rootBundle.loadString(AssetConstants.labels);
      _labels = raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (e) {
      _interpreter = null;
      throw ModelLoadException(
        'Failed to load the detection model. Make sure detect.tflite exists in assets/models/.',
        e,
      );
    }
  }

  /// Runs the SSD model on an RGB buffer of `size x size x 3` bytes.
  List<Detection> run(Uint8List rgb, {required double threshold}) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw const InferenceException('Model is not loaded.');
    }
    const n = AppConstants.maxDetections;
    const size = AppConstants.modelInputSize;

    final input = rgb.reshape([1, size, size, 3]);
    final locations = [List.generate(n, (_) => List<double>.filled(4, 0))];
    final classes = [List<double>.filled(n, 0)];
    final scores = [List<double>.filled(n, 0)];
    final count = List<double>.filled(1, 0);

    try {
      interpreter.runForMultipleInputs(
        [input],
        {0: locations, 1: classes, 2: scores, 3: count},
      );
    } catch (e) {
      throw InferenceException('Inference failed.', e);
    }

    return parseDetections(
      locations: locations[0],
      classes: classes[0],
      scores: scores[0],
      count: count[0].toInt(),
      threshold: threshold,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

/// Converts raw SSD outputs into [Detection]s above [threshold].
/// Boxes arrive as `[ymin, xmin, ymax, xmax]`, normalized to 0..1.
List<Detection> parseDetections({
  required List locations,
  required List classes,
  required List scores,
  required int count,
  required double threshold,
}) {
  final results = <Detection>[];
  final total = math.min(count, scores.length);
  for (var i = 0; i < total; i++) {
    final score = (scores[i] as num).toDouble();
    if (score < threshold) continue;
    final box = locations[i] as List;
    double c(int k) => (box[k] as num).toDouble().clamp(0.0, 1.0).toDouble();
    results.add(
      Detection(
        classIndex: (classes[i] as num).toInt(),
        score: score,
        box: Rect.fromLTRB(c(1), c(0), c(3), c(2)),
      ),
    );
  }
  return results;
}
