class AppConstants {
  AppConstants._();

  static const String appName = 'Object Detection';

  /// SSD MobileNet input resolution (width == height).
  static const int modelInputSize = 300;
  static const int maxDetections = 10;

  /// labels.txt starts with a "???" placeholder line, so the model's
  /// class index must be shifted by one to get the right label.
  static const int labelOffset = 1;

  static const double defaultConfidenceThreshold = 0.5;
  static const double minConfidenceThreshold = 0.1;
  static const double maxConfidenceThreshold = 0.95;
}
