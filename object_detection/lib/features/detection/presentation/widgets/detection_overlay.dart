import 'package:flutter/material.dart';

import '../../domain/entities/detected_object.dart';
import 'bounding_box.dart';

class DetectionOverlay extends StatelessWidget {
  const DetectionOverlay({super.key, required this.objects});

  final List<DetectedObject> objects;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: [
            for (final object in objects)
              BoundingBox(
                key: ValueKey(object.id),
                object: object,
                canvasSize: size,
              ),
          ],
        );
      },
    );
  }
}
