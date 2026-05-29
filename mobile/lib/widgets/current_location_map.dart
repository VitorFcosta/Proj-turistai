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

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
                  child: const Icon(
                    Icons.my_location,
                    color: Color(0xFF0F766E),
                    size: 36,
                  ),
                ),
                for (final place in places)
                  Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 42,
                    height: 42,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFDC2626),
                      size: 34,
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
