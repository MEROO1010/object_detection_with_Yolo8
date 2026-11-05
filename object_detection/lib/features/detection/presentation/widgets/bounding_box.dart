import 'package:flutter/material.dart';

import '../../domain/entities/detected_object.dart';

class BoundingBox extends StatelessWidget {
  const BoundingBox({super.key, required this.object, required this.canvasSize});

  final DetectedObject object;
  final Size canvasSize;

  static Color colorFor(String label) =>
      Colors.primaries[label.hashCode.abs() % Colors.primaries.length].shade400;

  @override
  Widget build(BuildContext context) {
    final rect = object.boundingBox;
    final color = colorFor(object.label);

    return Positioned(
      left: rect.left * canvasSize.width,
      top: rect.top * canvasSize.height,
      width: rect.width * canvasSize.width,
      height: rect.height * canvasSize.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(6)),
            ),
            child: Text(
              '${object.label} ${object.confidencePercent}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
