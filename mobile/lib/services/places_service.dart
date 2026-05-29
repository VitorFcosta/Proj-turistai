import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum PlaceCategory { food, culture, nature, study, tourism, general }

class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final double distanceMeters;
}

class PlacesFailure implements Exception {
  const PlacesFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class PlacesService {
  PlacesService({http.Client? client}) : client = client ?? http.Client();

  static final Uri _overpassEndpoint = Uri.parse(
    'https://overpass-api.de/api/interpreter',
  );

  final http.Client client;

  Future<List<NearbyPlace>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required PlaceCategory category,
  }) async {
    final query = _buildOverpassQuery(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      category: category,
    );

    final response = await client.post(
      _overpassEndpoint,
      headers: const {'Content-Type': 'text/plain; charset=utf-8'},
      body: query,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const PlacesFailure(
        'Nao foi possivel buscar locais proximos agora.',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const PlacesFailure('Resposta invalida do OpenStreetMap.');
    }

    final elements = payload['elements'];
    if (elements is! List<dynamic>) {
      return const [];
    }

    final origin = LatLng(latitude, longitude);
    final distance = const Distance();

    return elements
        .whereType<Map<String, dynamic>>()
        .map((element) => _parsePlace(element, origin, distance))
        .nonNulls
        .take(12)
        .toList();
  }

  String _buildOverpassQuery({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required PlaceCategory category,
  }) {
    final filters = _filtersFor(category);

    return '''
[out:json][timeout:10];
(
${filters.map((filter) => _queryBlock(filter, radiusMeters, latitude, longitude)).join('\n')}
);
out center tags 20;
''';
  }

  List<String> _filtersFor(PlaceCategory category) {
    return switch (category) {
      PlaceCategory.food => ['["amenity"~"restaurant|cafe|fast_food|bar|pub"]'],
      PlaceCategory.culture => [
        '["tourism"~"museum|gallery|attraction|artwork"]',
        '["amenity"~"theatre|arts_centre"]',
      ],
      PlaceCategory.nature => [
        '["leisure"~"park|garden"]',
        '["natural"~"wood|beach|viewpoint"]',
      ],
      PlaceCategory.study => ['["amenity"~"library|university|college"]'],
      PlaceCategory.tourism => [
        '["tourism"~"attraction|museum|viewpoint|artwork"]',
        '["historic"]',
      ],
      PlaceCategory.general => [
        '["amenity"~"restaurant|cafe|fast_food|bar|pub|library|university|college|school|theatre|arts_centre|place_of_worship|fuel|pharmacy|bank|post_office|townhall|community_centre|hospital|clinic|police|bus_station"]',
        '["shop"~"supermarket|bakery|convenience|mall|kiosk"]',
        '["tourism"~"attraction|museum|gallery|viewpoint|artwork"]',
        '["leisure"~"park|garden|sports_centre|pitch|playground"]',
        '["natural"~"wood|beach|viewpoint"]',
        '["historic"]',
        '["healthcare"]',
        '["public_transport"]',
        '["place"~"village|town|hamlet|locality|neighbourhood"]',
      ],
    };
  }

  String _queryBlock(
    String filter,
    int radiusMeters,
    double latitude,
    double longitude,
  ) {
    final around = '(around:$radiusMeters,$latitude,$longitude)';

    return '''
  node$filter$around;
  way$filter$around;
  relation$filter$around;
''';
  }

  NearbyPlace? _parsePlace(
    Map<String, dynamic> element,
    LatLng origin,
    Distance distance,
  ) {
    final tags = element['tags'];
    if (tags is! Map<String, dynamic>) {
      return null;
    }

    final name = tags['name'];
    if (name is! String || name.trim().isEmpty) {
      return null;
    }

    final latitude = _readCoordinate(element, 'lat');
    final longitude = _readCoordinate(element, 'lon');
    if (latitude == null || longitude == null) {
      return null;
    }

    final point = LatLng(latitude, longitude);

    return NearbyPlace(
      id: '${element['type']}-${element['id']}',
      name: name,
      type: _readPlaceType(tags),
      latitude: latitude,
      longitude: longitude,
      distanceMeters: distance.as(LengthUnit.Meter, origin, point),
    );
  }

  double? _readCoordinate(Map<String, dynamic> element, String key) {
    final value = element[key];
    if (value is num) {
      return value.toDouble();
    }

    final center = element['center'];
    if (center is Map<String, dynamic>) {
      final centerValue = center[key];
      if (centerValue is num) {
        return centerValue.toDouble();
      }
    }

    return null;
  }

  String _readPlaceType(Map<String, dynamic> tags) {
    for (final key in [
      'tourism',
      'amenity',
      'shop',
      'leisure',
      'natural',
      'historic',
      'healthcare',
      'public_transport',
      'place',
    ]) {
      final value = tags[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return 'place';
  }
}
