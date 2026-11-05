import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({super.key, required this.value});

  /// 0..1
  final double value;

  static Color colorFor(double value) {
    if (value >= 0.75) return Colors.greenAccent.shade400;
    if (value >= 0.5) return Colors.amber;
    return Colors.deepOrangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(value);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              color: color,
              backgroundColor: Colors.white24,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).round()}%',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
