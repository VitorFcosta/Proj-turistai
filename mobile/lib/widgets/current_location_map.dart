import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:touristai/services/location_service.dart';
import 'package:touristai/services/places_service.dart';

class CurrentLocationMap extends StatelessWidget {
  const CurrentLocationMap({
    required this.location,
    required this.places,
    super.key,
  });

  final UserLocation location;
  final List<NearbyPlace> places;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(location.latitude, location.longitude);
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'br.edu.touristai',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 48,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Color(0xFFBF3003),
                      size: 30,
                    ),
                  ),
                ),
                for (final place in places)
                  Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 42,
                    height: 42,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Colors.white,
                        size: 24,
                      ),
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
