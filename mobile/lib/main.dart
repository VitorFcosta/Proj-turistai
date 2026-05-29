import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:touristai/services/location_service.dart';
import 'package:touristai/services/places_service.dart';
import 'package:touristai/services/recommendation_service.dart';

void main() {
  runApp(const TouristAiApp());
}

class TouristAiApp extends StatelessWidget {
  const TouristAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TouristAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({
    LocationService? locationService,
    PlacesService? placesService,
    RecommendationService? recommendationService,
    super.key,
  }) : locationService = locationService ?? LocationService(),
       placesService = placesService ?? PlacesService(),
       recommendationService = recommendationService ?? RecommendationService();

  final LocationService locationService;
  final PlacesService placesService;
  final RecommendationService recommendationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String category = 'Cultura';
  String availableTime = '1 hora';
  String budget = 'Baixo';
  String transportMode = 'A pe';
  String searchRadius = '15 km';
  UserLocation? currentLocation;
  List<NearbyPlace> nearbyPlaces = const [];
  RecommendationResult? recommendation;
  String? locationError;
  String? placesError;
  String? placesNotice;
  String? recommendationError;
  bool isFindingLocation = false;
  bool isGeneratingRecommendation = false;
  bool hasSearchedPlaces = false;

  Future<void> findNearbyPlaces() async {
    setState(() {
      isFindingLocation = true;
      locationError = null;
      placesError = null;
      placesNotice = null;
      recommendationError = null;
      currentLocation = null;
      nearbyPlaces = const [];
      recommendation = null;
      hasSearchedPlaces = false;
    });

    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }

      setState(() {
        currentLocation = location;
      });

      var places = await widget.placesService.fetchNearbyPlaces(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusMeters: selectedRadiusMeters,
        category: selectedPlaceCategory,
      );
      String? notice;

      if (places.isEmpty) {
        places = await widget.placesService.fetchNearbyPlaces(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusMeters: selectedRadiusMeters,
          category: PlaceCategory.general,
        );
        if (places.isNotEmpty) {
          notice =
              'Nenhum local da categoria escolhida foi encontrado em $searchRadius. Mostrando opcoes gerais no mesmo raio.';
        }
      }

      if (places.isEmpty && selectedRadiusMeters < 5000) {
        places = await widget.placesService.fetchNearbyPlaces(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusMeters: 5000,
          category: PlaceCategory.general,
        );
        if (places.isNotEmpty) {
          notice =
              'Nenhum local da categoria escolhida foi encontrado em 1,5 km. Mostrando opcoes gerais em ate 5 km.';
        }
      }

      if (places.isEmpty && selectedRadiusMeters < 15000) {
        places = await widget.placesService.fetchNearbyPlaces(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusMeters: 15000,
          category: PlaceCategory.general,
        );
        if (places.isNotEmpty) {
          notice =
              'Nenhum local proximo foi encontrado em 5 km. Mostrando opcoes gerais em ate 15 km.';
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        nearbyPlaces = places;
        placesNotice = notice;
        hasSearchedPlaces = true;
      });
    } on LocationFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        locationError = error.message;
      });
    } on PlacesFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        placesError = error.message;
        placesNotice = null;
        hasSearchedPlaces = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          isFindingLocation = false;
        });
      }
    }
  }

  Future<void> generateRecommendations() async {
    final location = currentLocation;
    if (location == null || nearbyPlaces.isEmpty) {
      return;
    }

    setState(() {
      isGeneratingRecommendation = true;
      recommendationError = null;
      recommendation = null;
    });

    try {
      final result = await widget.recommendationService.generateRecommendations(
        location: location,
        radiusMeters: selectedRadiusMeters,
        preferences: selectedUserPreferences,
        places: nearbyPlaces,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        recommendation = result;
      });
    } on RecommendationFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        recommendationError = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        recommendationError =
            'Erro de ligação. Verifique se o backend está a ser executado e se o IP configurado está correto.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingRecommendation = false;
        });
      }
    }
  }

  PlaceCategory get selectedPlaceCategory {
    return switch (category) {
      'Comida' => PlaceCategory.food,
      'Natureza' => PlaceCategory.nature,
      'Estudo' => PlaceCategory.study,
      'Turismo' => PlaceCategory.tourism,
      _ => PlaceCategory.culture,
    };
  }

  int get selectedRadiusMeters {
    return switch (searchRadius) {
      '1,5 km' => 1500,
      '5 km' => 5000,
      '30 km' => 30000,
      _ => 15000,
    };
  }

  UserPreferences get selectedUserPreferences {
    return UserPreferences(
      category: switch (category) {
        'Comida' => 'comida',
        'Natureza' => 'natureza',
        'Estudo' => 'estudo',
        'Turismo' => 'turismo',
        _ => 'cultura',
      },
      availableMinutes: switch (availableTime) {
        '30 minutos' => 30,
        '2 horas' => 120,
        _ => 60,
      },
      budget: switch (budget) {
        'Gratis' => 'gratis',
        'Medio' => 'medio',
        _ => 'baixo',
      },
      transportMode: transportMode == 'Carro' ? 'carro' : 'a_pe',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TouristAI')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Icon(Icons.explore, size: 56),
            const SizedBox(height: 12),
            Text(
              'Descubra lugares proximos com IA',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Informe suas preferencias para encontrar um roteiro perto de voce.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PreferenceDropdown(
              label: 'Categoria',
              value: category,
              options: const [
                'Cultura',
                'Comida',
                'Natureza',
                'Estudo',
                'Turismo',
              ],
              onChanged: (value) => setState(() => category = value),
            ),
            const SizedBox(height: 12),
            PreferenceDropdown(
              label: 'Tempo disponivel',
              value: availableTime,
              options: const ['30 minutos', '1 hora', '2 horas'],
              onChanged: (value) => setState(() => availableTime = value),
            ),
            const SizedBox(height: 12),
            PreferenceDropdown(
              label: 'Orcamento',
              value: budget,
              options: const ['Gratis', 'Baixo', 'Medio'],
              onChanged: (value) => setState(() => budget = value),
            ),
            const SizedBox(height: 12),
            PreferenceDropdown(
              label: 'Deslocamento',
              value: transportMode,
              options: const ['A pe', 'Carro'],
              onChanged: (value) => setState(() => transportMode = value),
            ),
            const SizedBox(height: 12),
            PreferenceDropdown(
              label: 'Raio de busca',
              value: searchRadius,
              options: const ['1,5 km', '5 km', '15 km', '30 km'],
              onChanged: (value) => setState(() => searchRadius = value),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isFindingLocation ? null : findNearbyPlaces,
              icon: const Icon(Icons.my_location),
              label: Text(
                isFindingLocation
                    ? 'Buscando localizacao...'
                    : 'Encontrar locais proximos',
              ),
            ),
            const SizedBox(height: 16),
            if (currentLocation != null)
              LocationStatusCard(
                title: 'Localizacao encontrada',
                message:
                    'Latitude: ${currentLocation!.latitude}\nLongitude: ${currentLocation!.longitude}',
              ),
            if (hasSearchedPlaces) ...[
              const SizedBox(height: 16),
              PlacesSummaryCard(places: nearbyPlaces, notice: placesNotice),
            ],
            if (nearbyPlaces.isNotEmpty) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: isGeneratingRecommendation
                    ? null
                    : generateRecommendations,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  isGeneratingRecommendation
                      ? 'Gerando roteiro...'
                      : 'Gerar roteiro com IA',
                ),
              ),
            ],
            if (recommendation != null) ...[
              const SizedBox(height: 16),
              RecommendationCard(result: recommendation!),
            ],
            if (recommendationError != null) ...[
              const SizedBox(height: 16),
              LocationStatusCard(
                title: 'Nao foi possivel gerar roteiro',
                message: recommendationError!,
              ),
            ],
            if (currentLocation != null) ...[
              const SizedBox(height: 16),
              CurrentLocationMap(
                location: currentLocation!,
                places: nearbyPlaces,
              ),
            ],
            if (locationError != null)
              LocationStatusCard(
                title: 'Nao foi possivel obter localizacao',
                message: locationError!,
              ),
            if (placesError != null)
              LocationStatusCard(
                title: 'Nao foi possivel buscar locais',
                message: placesError!,
              ),
            if (hasSearchedPlaces && nearbyPlaces.isEmpty)
              const LocationStatusCard(
                title: 'Roteiro indisponivel',
                message:
                    'A IA precisa de pelo menos um local encontrado. Tente outra categoria, outra regiao ou novamente com internet melhor.',
              ),
          ],
        ),
      ),
    );
  }
}

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

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({required this.result, super.key});

  final RecommendationResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(result.summary),
            const SizedBox(height: 12),
            for (final item in result.recommendations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.suggestedOrder}. ${item.placeName}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(item.reason),
                    Text(item.tip),
                  ],
                ),
              ),
            Text(result.generalTip),
          ],
        ),
      ),
    );
  }
}

class LocationStatusCard extends StatelessWidget {
  const LocationStatusCard({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class PreferenceDropdown extends StatelessWidget {
  const PreferenceDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: (selected) {
        if (selected == null) {
          return;
        }

        onChanged(selected);
      },
    );
  }
}
