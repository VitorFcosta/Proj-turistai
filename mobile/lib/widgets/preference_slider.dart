import 'package:flutter/material.dart';

class PreferenceSlider extends StatelessWidget {
  const PreferenceSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
    this.sliderKey,
    super.key,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final Key? sliderKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              key: sliderKey,
              min: min,
              max: max,
              value: value.clamp(min, max),
              activeColor: colorScheme.primary,
              inactiveColor: const Color(0xFFC3C5D9),
              onChanged: onChanged,
            ),
            Row(
              children: [
                Text(
                  _formatLimit(min),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatLimit(max),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLimit(double limit) {
    if (max <= 240) {
      return '${limit.round()} min';
    }

    if (limit < 1000) {
      return '${limit.round()} m';
    }

    return '${(limit / 1000).round()} km';
  }
}
