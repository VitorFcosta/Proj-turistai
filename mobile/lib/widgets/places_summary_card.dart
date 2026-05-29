import 'package:flutter/material.dart';
import 'package:touristai/services/places_service.dart';

class PlacesSummaryCard extends StatelessWidget {
  const PlacesSummaryCard({required this.places, this.notice, super.key});

  final List<NearbyPlace> places;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    final countLabel = places.length == 1
        ? '1 local encontrado'
        : '${places.length} locais encontrados';
    final visiblePlaces = [...places]
      ..sort(
        (left, right) => left.distanceMeters.compareTo(right.distanceMeters),
      );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(countLabel, style: Theme.of(context).textTheme.titleMedium),
            if (places.length > 5) ...[
              const SizedBox(height: 8),
              const Text('Mostrando os 5 mais proximos.'),
            ],
            if (notice != null) ...[const SizedBox(height: 8), Text(notice!)],
            const SizedBox(height: 8),
            if (places.isEmpty)
              const Text('Tente trocar a categoria ou buscar em outro local.')
            else
              for (final place in visiblePlaces.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${place.name} - ${place.distanceMeters.round()}m',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
