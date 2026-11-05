import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../state/detection_state.dart';
import 'bounding_box.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({super.key, required this.state});

  final DetectionState state;

  @override
  Widget build(BuildContext context) {
    final counts = state.countsByLabel;
    return AppCard(
      color: Colors.black.withAlpha(150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(label: 'FPS', value: state.fps.toStringAsFixed(1)),
              _Stat(label: 'Objects', value: '${state.objects.length}'),
              _Stat(
                label: 'Min confidence',
                value: '${(state.confidenceThreshold * 100).round()}%',
              ),
            ],
          ),
          if (counts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final entry in counts.entries)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: BoundingBox.colorFor(entry.key).withAlpha(200),
                    side: BorderSide.none,
                    label: Text(
                      '${entry.key} × ${entry.value}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: theme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.labelSmall?.copyWith(color: Colors.white70)),
      ],
    );
  }
}
