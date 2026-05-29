import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:touristai/main.dart';
import 'package:touristai/screens/home_screen.dart';
import 'package:touristai/services/location_service.dart';
import 'package:touristai/services/places_service.dart';
import 'package:touristai/services/recommendation_service.dart';
import 'package:touristai/widgets/places_summary_card.dart';

void main() {
  testWidgets('shows TouristAI home screen with preference controls', (
    tester,
  ) async {
    await tester.pumpWidget(const TouristAiApp());

    expect(find.text('TouristAI'), findsOneWidget);
    expect(find.text('Descubra lugares proximos com IA'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Tempo disponivel'), findsOneWidget);
    expect(find.text('Orcamento'), findsOneWidget);
    expect(find.text('Deslocamento'), findsOneWidget);
    expect(find.text('Raio de busca'), findsOneWidget);
    expect(find.text('Encontrar locais proximos'), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
  });

  testWidgets('uses selected search radius when finding nearby places', (
    tester,
  ) async {
    String? requestBody;
    final placesService = PlacesService(
      client: MockClient((request) async {
        requestBody = request.body;

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
    }
  ]
}
''', 200);
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: _locationService(),
          placesService: placesService,
        ),
      ),
    );

    await tester.tap(find.text('15 km'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 km').last);
    await tester.pumpAndSettle();
    await _tapFindNearby(tester);

    expect(requestBody, contains('around:30000'));
  });

  testWidgets('shows current coordinates after finding nearby places', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: LocationService(
            isLocationServiceEnabled: () async => true,
            checkPermission: () async => LocationPermission.whileInUse,
            requestPermission: () async => LocationPermission.whileInUse,
            getCurrentPosition: () async =>
                _position(latitude: -23.55052, longitude: -46.633308),
          ),
        ),
      ),
    );

    await _tapFindNearby(tester);

    expect(find.text('Localizacao encontrada'), findsOneWidget);
    expect(find.textContaining('-23.55052'), findsOneWidget);
    expect(find.textContaining('-46.633308'), findsOneWidget);
  });

  testWidgets('shows OpenStreetMap after finding current location', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: LocationService(
            isLocationServiceEnabled: () async => true,
            checkPermission: () async => LocationPermission.whileInUse,
            requestPermission: () async => LocationPermission.whileInUse,
            getCurrentPosition: () async =>
                _position(latitude: -23.55052, longitude: -46.633308),
          ),
        ),
      ),
    );

    await _tapFindNearby(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('shows nearby places after finding current location', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: _locationService(),
          placesService: _placesService(),
        ),
      ),
    );

    await _tapFindNearby(tester);

    expect(
      find.text('1 local encontrado', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining('Museu Exemplo', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('explains when only five closest places are displayed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlacesSummaryCard(
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
          ),
        ),
      ),
    );

    expect(find.text('6 locais encontrados'), findsOneWidget);
    expect(find.text('Mostrando os 5 mais proximos.'), findsOneWidget);
    expect(find.textContaining('Local 1'), findsOneWidget);
    expect(find.textContaining('Local 5'), findsOneWidget);
    expect(find.textContaining('Local 6'), findsNothing);
  });

  testWidgets('uses wider search when selected category returns no places', (
    tester,
  ) async {
    var requestCount = 0;
    final placesService = PlacesService(
      client: MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          return http.Response('{"elements":[]}', 200);
        }

        return http.Response('''
{
  "elements": [
    {
      "type": "node",
      "id": 789,
      "lat": -23.553,
      "lon": -46.636,
      "tags": {
        "name": "Parque Exemplo",
        "leisure": "park"
      }
    }
  ]
}
''', 200);
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: _locationService(),
          placesService: placesService,
        ),
      ),
    );

    await _tapFindNearby(tester);

    expect(requestCount, 2);
    expect(
      find.textContaining('Mostrando opcoes gerais', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining('Parque Exemplo', skipOffstage: false),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(
      find.text('Gerar roteiro com IA', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('uses regional search when nearby searches return no places', (
    tester,
  ) async {
    var requestCount = 0;
    final placesService = PlacesService(
      client: MockClient((request) async {
        requestCount++;
        if (requestCount < 4) {
          return http.Response('{"elements":[]}', 200);
        }

        expect(request.body, contains('around:15000'));
        return http.Response('''
{
  "elements": [
    {
      "type": "node",
      "id": 900,
      "lat": -20.61,
      "lon": -47.49,
      "tags": {
        "name": "Mercado Exemplo",
        "shop": "supermarket"
      }
    }
  ]
}
''', 200);
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: _locationService(),
          placesService: placesService,
        ),
      ),
    );

    await tester.tap(find.text('15 km'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1,5 km').last);
    await tester.pumpAndSettle();
    await _tapFindNearby(tester);

    expect(requestCount, 4);
    expect(
      find.textContaining('ate 15 km', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining('Mercado Exemplo', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('shows mock AI route after generating recommendations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: _locationService(),
          placesService: _placesService(),
          recommendationService: _recommendationService(),
        ),
      ),
    );

    await _tapFindNearby(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gerar roteiro com IA', skipOffstage: false));
    await tester.pumpAndSettle();

    expect(
      find.text('Roteiro cultural proximo', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining('Museu Exemplo', skipOffstage: false),
      findsWidgets,
    );
    expect(
      find.textContaining('Confira o horario', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('shows AI error near generate button when backend fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: _locationService(),
          placesService: _placesService(),
          recommendationService: _failingRecommendationService(),
        ),
      ),
    );

    await _tapFindNearby(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gerar roteiro com IA', skipOffstage: false));
    await tester.pumpAndSettle();

    expect(
      find.text('Nao foi possivel gerar roteiro', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Nao foi possivel gerar o roteiro agora.', skipOffstage: false),
      findsOneWidget,
    );
  });
}

Future<void> _tapFindNearby(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -260));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Encontrar locais proximos'));
  await tester.pumpAndSettle();
}

LocationService _locationService() {
  return LocationService(
    isLocationServiceEnabled: () async => true,
    checkPermission: () async => LocationPermission.whileInUse,
    requestPermission: () async => LocationPermission.whileInUse,
    getCurrentPosition: () async =>
        _position(latitude: -23.55052, longitude: -46.633308),
  );
}

PlacesService _placesService() {
  final client = MockClient((request) async {
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
    }
  ]
}
''', 200);
  });

  return PlacesService(client: client);
}

RecommendationService _recommendationService() {
  final client = MockClient((request) async {
    return http.Response('''
{
  "title": "Roteiro cultural proximo",
  "summary": "Sugestao para 1 hora.",
  "recommendations": [
    {
      "placeId": "node-123",
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

  return RecommendationService(client: client);
}

RecommendationService _failingRecommendationService() {
  final client = MockClient((request) async {
    return http.Response('{"error":"ai_provider_error"}', 502);
  });

  return RecommendationService(client: client);
}

Position _position({required double latitude, required double longitude}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime(2026, 5, 29),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}
