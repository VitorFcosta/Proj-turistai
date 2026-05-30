import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:touristai/screens/home_screen.dart';
import 'package:touristai/services/location_service.dart';
import 'package:touristai/services/places_service.dart';
import 'package:touristai/services/recommendation_service.dart';
import 'package:touristai/widgets/places_summary_card.dart';

void main() {
  testWidgets('shows Stitch-style start screen and opens preferences', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(locationService: _locationService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('TouristAI'), findsOneWidget);
    expect(find.text('Nova exploração'), findsOneWidget);
    expect(
      find.textContaining('Descubra roteiros próximos com IA'),
      findsNothing,
    );
    expect(find.text('Sua localização atual'), findsOneWidget);
    expect(find.textContaining('-23.55052'), findsOneWidget);
    expect(find.textContaining('-46.633308'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing);
    expect(find.byIcon(Icons.explore), findsWidgets);

    await tester.tap(find.text('Nova exploração'));
    await tester.pumpAndSettle();

    expect(find.text('Personalize seu roteiro'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Tempo disponível'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('available-minutes-slider')),
      findsOneWidget,
    );
    expect(find.text('30 minutos'), findsNothing);
    expect(find.text('2 horas'), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('radius-meters-slider')),
      180,
    );
    expect(find.text('Orçamento'), findsOneWidget);
    expect(find.text('Deslocamento'), findsOneWidget);
    expect(find.text('Raio de busca'), findsOneWidget);
    expect(find.byKey(const ValueKey('radius-meters-slider')), findsOneWidget);
    expect(find.text('1,5 km'), findsNothing);
    expect(find.text('Encontrar locais próximos'), findsOneWidget);
  });

  testWidgets('does not show start map until GPS is available', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(locationService: _slowLocationService())),
    );

    expect(find.text('Buscando sua localização...'), findsOneWidget);
    expect(find.byType(FlutterMap), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Sua localização atual'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('shows GPS warning instead of map when start location fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(locationService: _disabledLocationService()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Localização não carregada'), findsOneWidget);
    expect(find.textContaining('Ative a localizacao'), findsOneWidget);
    expect(find.byType(FlutterMap), findsNothing);
    expect(find.text('Nova exploração'), findsOneWidget);
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

    await _openPreferences(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('radius-meters-slider')),
      180,
    );
    tester
        .widget<Slider>(find.byKey(const ValueKey('radius-meters-slider')))
        .onChanged!(30000);
    await tester.pumpAndSettle();
    await _tapFindNearby(tester);

    expect(requestBody, contains('around:30000'));
  });

  testWidgets(
    'uses selected available minutes when generating recommendations',
    (tester) async {
      String? recommendationBody;
      final recommendationService = RecommendationService(
        client: MockClient((request) async {
          recommendationBody = request.body;

          return http.Response('''
{
  "title": "Roteiro cultural proximo",
  "summary": "Sugestao para o tempo escolhido.",
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
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            locationService: _locationService(),
            placesService: _placesService(),
            recommendationService: recommendationService,
          ),
        ),
      );

      await _openPreferences(tester);
      tester
          .widget<Slider>(
            find.byKey(const ValueKey('available-minutes-slider')),
          )
          .onChanged!(240);
      await tester.pumpAndSettle();
      await _tapFindNearby(tester);
      await tester.tap(find.text('Gerar roteiro com IA', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(recommendationBody, contains('"availableMinutes":240'));
    },
  );

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

    expect(find.text('Localização atual'), findsOneWidget);
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

    expect(find.text('Locais próximos'), findsOneWidget);
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
    expect(find.text('Mostrando os 5 mais próximos.'), findsOneWidget);
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
      find.textContaining('Mostrando opções gerais', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining('Parque Exemplo', skipOffstage: false),
      findsOneWidget,
    );
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

    await _openPreferences(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('radius-meters-slider')),
      180,
    );
    tester
        .widget<Slider>(find.byKey(const ValueKey('radius-meters-slider')))
        .onChanged!(500);
    await tester.pumpAndSettle();
    await _tapFindNearby(tester);

    expect(requestCount, 4);
    expect(
      find.textContaining('até 15 km', skipOffstage: false),
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
    await tester.tap(find.text('Gerar roteiro com IA', skipOffstage: false));
    await tester.pumpAndSettle();

    expect(
      find.text('Seu roteiro sugerido', skipOffstage: false),
      findsOneWidget,
    );
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

  testWidgets('shows AI loading screen while recommendation is pending', (
    tester,
  ) async {
    final recommendationService = RecommendationService(
      client: MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
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
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          locationService: _locationService(),
          placesService: _placesService(),
          recommendationService: recommendationService,
        ),
      ),
    );

    await _tapFindNearby(tester);
    await tester.tap(find.text('Gerar roteiro com IA', skipOffstage: false));
    await tester.pump();

    expect(find.text('Consultando o TouristAI...'), findsOneWidget);
    expect(find.text('IA trabalhando...'), findsOneWidget);

    await tester.pumpAndSettle();
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
    await tester.tap(find.text('Gerar roteiro com IA', skipOffstage: false));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível gerar roteiro', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Nao foi possivel gerar o roteiro agora.', skipOffstage: false),
      findsOneWidget,
    );
  });
}

Future<void> _tapFindNearby(WidgetTester tester) async {
  await _openPreferences(tester);
  await tester.tap(find.text('Encontrar locais próximos'));
  await tester.pumpAndSettle();
}

Future<void> _openPreferences(WidgetTester tester) async {
  if (find.text('Nova exploração').evaluate().isNotEmpty) {
    await tester.tap(find.text('Nova exploração'));
    await tester.pumpAndSettle();
  }
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

LocationService _slowLocationService() {
  return LocationService(
    isLocationServiceEnabled: () async => true,
    checkPermission: () async => LocationPermission.whileInUse,
    requestPermission: () async => LocationPermission.whileInUse,
    getCurrentPosition: () async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return _position(latitude: -23.55052, longitude: -46.633308);
    },
  );
}

LocationService _disabledLocationService() {
  return LocationService(
    isLocationServiceEnabled: () async => false,
    checkPermission: () async => LocationPermission.denied,
    requestPermission: () async => LocationPermission.denied,
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
