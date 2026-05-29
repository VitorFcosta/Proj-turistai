import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:touristai/services/places_service.dart';

void main() {
  test('fetches named nearby places from Overpass response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'https://overpass-api.de/api/interpreter');
      expect(request.body, contains('around:1500,-23.55052,-46.633308'));

      return http.Response('''
{
  "elements": [
    {
      "type": "node",
      "id": 123,
      "lat": -23.551,
      "lon": -46.634,
      "tags": {
        "name": "Museu Exemplo",
        "tourism": "museum"
      }
    },
    {
      "type": "node",
      "id": 456,
      "lat": -23.552,
      "lon": -46.635,
      "tags": {
        "tourism": "attraction"
      }
    }
  ]
}
''', 200);
    });

    final service = PlacesService(client: client);

    final places = await service.fetchNearbyPlaces(
      latitude: -23.55052,
      longitude: -46.633308,
      radiusMeters: 1500,
      category: PlaceCategory.culture,
    );

    expect(places, hasLength(1));
    expect(places.first.id, 'node-123');
    expect(places.first.name, 'Museu Exemplo');
    expect(places.first.type, 'museum');
    expect(places.first.latitude, -23.551);
    expect(places.first.longitude, -46.634);
    expect(places.first.distanceMeters, greaterThan(0));
  });

  test('sorts nearby places by distance before returning results', () async {
    final client = MockClient((request) async {
      return http.Response('''
{
  "elements": [
    {
      "type": "node",
      "id": 1,
      "lat": 0.02,
      "lon": 0.0,
      "tags": {
        "name": "Local distante",
        "tourism": "attraction"
      }
    },
    {
      "type": "node",
      "id": 2,
      "lat": 0.001,
      "lon": 0.0,
      "tags": {
        "name": "Local perto",
        "tourism": "attraction"
      }
    },
    {
      "type": "node",
      "id": 3,
      "lat": 0.01,
      "lon": 0.0,
      "tags": {
        "name": "Local medio",
        "tourism": "attraction"
      }
    }
  ]
}
''', 200);
    });

    final service = PlacesService(client: client);

    final places = await service.fetchNearbyPlaces(
      latitude: 0,
      longitude: 0,
      radiusMeters: 5000,
      category: PlaceCategory.culture,
    );

    expect(places.map((place) => place.name), [
      'Local perto',
      'Local medio',
      'Local distante',
    ]);
  });

  test('throws PlacesFailure when Overpass response is not successful', () {
    final client = MockClient((request) async {
      return http.Response('server error', 500);
    });

    final service = PlacesService(client: client);

    expect(
      () => service.fetchNearbyPlaces(
        latitude: -23.55052,
        longitude: -46.633308,
        radiusMeters: 1500,
        category: PlaceCategory.culture,
      ),
      throwsA(isA<PlacesFailure>()),
    );
  });
}
