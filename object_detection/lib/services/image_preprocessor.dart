import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../core/constants/app_constants.dart';

/// Converts a [CameraImage] (YUV420 on Android, BGRA8888 on iOS) into an
/// upright RGB byte buffer of size `target x target x 3` ready for the model.
///
/// Sampling is done directly at the target resolution (nearest neighbour),
/// so the full-resolution frame is never converted.
class ImagePreprocessor {
  const ImagePreprocessor({this.targetSize = AppConstants.modelInputSize});

  final int targetSize;

  Uint8List preprocess(CameraImage image, {int rotation = 0}) {
    final out = Uint8List(targetSize * targetSize * 3);
    final sw = image.width;
    final sh = image.height;
    final swapped = rotation == 90 || rotation == 270;
    final upW = swapped ? sh : sw;
    final upH = swapped ? sw : sh;
    final isYuv = image.format.group == ImageFormatGroup.yuv420;

    var o = 0;
    for (var ty = 0; ty < targetSize; ty++) {
      final uy = ty * upH ~/ targetSize;
      for (var tx = 0; tx < targetSize; tx++) {
        final ux = tx * upW ~/ targetSize;
        final (sx, sy) = sourceCoordinate(ux, uy, sw, sh, rotation);

        if (isYuv) {
          final yPlane = image.planes[0];
          final uPlane = image.planes[1];
          final vPlane = image.planes[2];
          final yVal = yPlane.bytes[sy * yPlane.bytesPerRow + sx];
          final uvIndex =
              (sy >> 1) * uPlane.bytesPerRow + (sx >> 1) * (uPlane.bytesPerPixel ?? 1);
          final (r, g, b) = yuvToRgb(yVal, uPlane.bytes[uvIndex], vPlane.bytes[uvIndex]);
          out[o++] = r;
          out[o++] = g;
          out[o++] = b;
        } else {
          final plane = image.planes[0];
          final i = sy * plane.bytesPerRow + sx * 4;
          out[o++] = plane.bytes[i + 2]; // R
          out[o++] = plane.bytes[i + 1]; // G
          out[o++] = plane.bytes[i]; // B
        }
      }
    }
    return out;
  }

  /// Maps a pixel of the upright (rotated) image back to the raw sensor frame.
  static (int, int) sourceCoordinate(int ux, int uy, int sw, int sh, int rotation) {
    switch (rotation) {
      case 90:
        return (uy, sh - 1 - ux);
      case 180:
        return (sw - 1 - ux, sh - 1 - uy);
      case 270:
        return (sw - 1 - uy, ux);
      default:
        return (ux, uy);
    }
  }

  static (int, int, int) yuvToRgb(int y, int u, int v) {
    final uu = u - 128;
    final vv = v - 128;
    final r = (y + 1.402 * vv).round().clamp(0, 255).toInt();
    final g = (y - 0.344136 * uu - 0.714136 * vv).round().clamp(0, 255).toInt();
    final b = (y + 1.772 * uu).round().clamp(0, 255).toInt();
    return (r, g, b);
  }
}
