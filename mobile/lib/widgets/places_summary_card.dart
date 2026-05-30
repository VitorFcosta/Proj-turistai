import 'package:flutter/material.dart';
import 'package:touristai/services/places_service.dart';

class PlacesSummaryCard extends StatelessWidget {
  const PlacesSummaryCard({required this.places, this.notice, super.key});

  final List<NearbyPlace> places;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final countLabel = places.length == 1
        ? '1 local encontrado'
        : '${places.length} locais encontrados';
    final visiblePlaces = [...places]
      ..sort(
        (left, right) => left.distanceMeters.compareTo(right.distanceMeters),
      );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.travel_explore, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    countLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (places.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                'Mostrando os 5 mais próximos.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
            if (notice != null) ...[
              const SizedBox(height: 8),
              Text(
                notice!,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            if (places.isEmpty)
              Text(
                'Tente trocar a categoria ou buscar em outro local.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            else
              for (final place in visiblePlaces.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _iconBackground(place.type),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconFor(place.type),
                          color: _iconColor(place.type),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${place.distanceMeters.round()}m de distância',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('restaurant') ||
        normalizedType.contains('cafe') ||
        normalizedType.contains('bar') ||
        normalizedType.contains('food')) {
      return Icons.restaurant;
    }
    if (normalizedType.contains('park') ||
        normalizedType.contains('garden') ||
        normalizedType.contains('nature')) {
      return Icons.park;
    }
    if (normalizedType.contains('school') ||
        normalizedType.contains('library') ||
        normalizedType.contains('university')) {
      return Icons.school;
    }
    if (normalizedType.contains('museum') ||
        normalizedType.contains('historic') ||
        normalizedType.contains('art')) {
      return Icons.account_balance;
    }

    return Icons.place;
  }

  Color _iconBackground(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('restaurant') ||
        normalizedType.contains('cafe') ||
        normalizedType.contains('bar') ||
        normalizedType.contains('food')) {
      return const Color(0xFFE2F7EC);
    }
    if (normalizedType.contains('park') ||
        normalizedType.contains('garden') ||
        normalizedType.contains('nature')) {
      return const Color(0xFFBFEDD5);
    }
    if (normalizedType.contains('school') ||
        normalizedType.contains('library') ||
        normalizedType.contains('university')) {
      return const Color(0xFFDDE1FF);
    }
    if (normalizedType.contains('museum') ||
        normalizedType.contains('historic') ||
        normalizedType.contains('art')) {
      return const Color(0xFFFFDBD2);
    }

    return const Color(0xFFF3F3F3);
  }

  Color _iconColor(String type) {
    final normalizedType = type.toLowerCase();

    if (normalizedType.contains('museum') ||
        normalizedType.contains('historic') ||
        normalizedType.contains('art')) {
      return const Color(0xFF952200);
    }
    if (normalizedType.contains('restaurant') ||
        normalizedType.contains('cafe') ||
        normalizedType.contains('bar') ||
        normalizedType.contains('food') ||
        normalizedType.contains('park') ||
        normalizedType.contains('garden') ||
        normalizedType.contains('nature')) {
      return const Color(0xFF3D6654);
    }

    return const Color(0xFF003EC7);
  }
}
