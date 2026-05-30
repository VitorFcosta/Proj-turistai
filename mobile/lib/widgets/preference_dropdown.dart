import 'package:flutter/material.dart';

class PreferenceDropdown extends StatelessWidget {
  const PreferenceDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

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
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in options)
                  ChoiceChip(
                    label: Text(option),
                    selected: option == value,
                    onSelected: (_) => onChanged(option),
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: const Color(0xFFF3F3F3),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: option == value
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: option == value
                          ? colorScheme.primary
                          : const Color(0xFFE2E2E2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
