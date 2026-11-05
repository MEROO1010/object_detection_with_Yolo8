import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/detection_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DetectionController>();
    final state = controller.state;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confidence threshold: ${(state.confidenceThreshold * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Detections below this score are hidden.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: state.confidenceThreshold,
                  min: AppConstants.minConfidenceThreshold,
                  max: AppConstants.maxConfidenceThreshold,
                  divisions: 17,
                  label: '${(state.confidenceThreshold * 100).round()}%',
                  onChanged: controller.setConfidenceThreshold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: const Text('Show statistics panel'),
              subtitle: const Text('FPS, object count and per-class totals'),
              value: state.showStatistics,
              onChanged: controller.setShowStatistics,
            ),
          ),
          const SizedBox(height: 12),
          const AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.memory),
              title: Text('Model'),
              subtitle: Text('COCO SSD MobileNet v1 (quantized) · 300×300'),
            ),
          ),
        ],
      ),
    );
  }
}