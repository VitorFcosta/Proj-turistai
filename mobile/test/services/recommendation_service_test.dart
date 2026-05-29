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
}
