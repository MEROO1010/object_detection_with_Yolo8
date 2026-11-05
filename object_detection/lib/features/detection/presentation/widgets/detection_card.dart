import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/detected_object.dart';
import 'bounding_box.dart';
import 'confidence_indicator.dart';

class DetectionCard extends StatelessWidget {
  const DetectionCard({super.key, required this.object});

  final DetectedObject object;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: AppCard(
        color: Colors.black.withAlpha(160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 5, backgroundColor: BoundingBox.colorFor(object.label)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    object.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConfidenceIndicator(value: object.confidence),
          ],
        ),
      ),
    );
  }
}
