import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:touristai/services/location_service.dart';
import 'package:touristai/services/places_service.dart';
import 'package:touristai/services/recommendation_service.dart';

void main() {
  test('posts recommendation request and parses response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'http://localhost:3000/api/recommendations',
      );
      expect(request.body, contains('"category":"cultura"'));
      expect(request.body, contains('"radiusMeters":5000'));
      expect(request.body, contains('"name":"Museu Exemplo"'));

      return http.Response('''
{
  "title": "Roteiro cultural proximo",
  "summary": "Sugestao para 1 hora.",
  "recommendations": [
    {
      "placeId": "node-1",
      "placeName": "Museu Exemplo",
      "suggestedOrder": 1,
      "reason": "Fica perto e combina com cultura.",
      "tip": "Comece por aqui."
    }
  ],
  "generalTip": "Confira o horario de funcionamento."
}
''', 200);
    });

    final service = RecommendationService(client: client);

    final result = await service.generateRecommendations(
      location: const UserLocation(latitude: -23.55052, longitude: -46.633308),
      radiusMeters: 5000,
      preferences: const UserPreferences(
        category: 'cultura',
        availableMinutes: 60,
        budget: 'baixo',
        transportMode: 'a_pe',
      ),
      places: const [
        NearbyPlace(
          id: 'node-1',
          name: 'Museu Exemplo',
          type: 'museum',
          latitude: -23.551,
          longitude: -46.634,
          distanceMeters: 350,
        ),
      ],
    );

    expect(result.title, 'Roteiro cultural proximo');
    expect(result.recommendations, hasLength(1));
    expect(result.recommendations.first.placeName, 'Museu Exemplo');
    expect(result.generalTip, 'Confira o horario de funcionamento.');
  });

  test('throws RecommendationFailure when backend returns error', () {
    final client = MockClient((request) async {
      return http.Response('{"error":"invalid_request"}', 400);
    });

    final service = RecommendationService(client: client);

    expect(
      () => service.generateRecommendations(
        location: const UserLocation(
          latitude: -23.55052,
          longitude: -46.633308,
        ),
        radiusMeters: 1500,
        preferences: const UserPreferences(
          category: 'cultura',
          availableMinutes: 60,
          budget: 'baixo',
          transportMode: 'a_pe',
        ),
        places: const [],
      ),
      throwsA(isA<RecommendationFailure>()),
    );
  });

  test('posts only five closest places to backend', () async {
    List<dynamic>? postedPlaces;
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      postedPlaces = body['places'] as List<dynamic>;

      return http.Response('''
{
  "title": "Roteiro cultural proximo",
  "summary": "Sugestao para 1 hora.",
  "recommendations": [
    {
      "placeId": "node-1",
      "placeName": "Local 1",
      "suggestedOrder": 1,
      "reason": "Fica perto.",
      "tip": "Comece por aqui."
    }
  ],
  "generalTip": "Confira o horario de funcionamento."
}
''', 200);
    });

    final service = RecommendationService(client: client);

    await service.generateRecommendations(
      location: const UserLocation(latitude: -23.55052, longitude: -46.633308),
      radiusMeters: 5000,
      preferences: const UserPreferences(
        category: 'cultura',
        availableMinutes: 60,
        budget: 'baixo',
        transportMode: 'a_pe',
      ),
      places: const [
        NearbyPlace(
          id: 'node-6',
          name: 'Local 6',
          type: 'museum',
          latitude: -23.556,
          longitude: -46.636,
          distanceMeters: 600,
        ),
        NearbyPlace(
          id: 'node-1',
          name: 'Local 1',
          type: 'museum',
          latitude: -23.551,
          longitude: -46.631,
          distanceMeters: 100,
        ),
        NearbyPlace(
          id: 'node-3',
          name: 'Local 3',
          type: 'museum',
          latitude: -23.553,
          longitude: -46.633,
          distanceMeters: 300,
        ),
        NearbyPlace(
          id: 'node-2',
          name: 'Local 2',
          type: 'museum',
          latitude: -23.552,
          longitude: -46.632,
          distanceMeters: 200,
        ),
        NearbyPlace(
          id: 'node-5',
          name: 'Local 5',
          type: 'museum',
          latitude: -23.555,
          longitude: -46.635,
          distanceMeters: 500,
        ),
        NearbyPlace(
          id: 'node-4',
          name: 'Local 4',
          type: 'museum',
          latitude: -23.554,
          longitude: -46.634,
          distanceMeters: 400,
        ),
      ],
    );

    expect(postedPlaces, hasLength(5));
    expect(postedPlaces!.map((place) => place['name']), [
      'Local 1',
      'Local 2',
      'Local 3',
      'Local 4',
      'Local 5',
    ]);
  });
}
