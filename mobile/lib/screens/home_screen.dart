import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:touristai/services/location_service.dart';
import 'package:touristai/services/places_service.dart';
import 'package:touristai/services/recommendation_service.dart';
import 'package:touristai/widgets/current_location_map.dart';
import 'package:touristai/widgets/location_status_card.dart';
import 'package:touristai/widgets/places_summary_card.dart';
import 'package:touristai/widgets/preference_dropdown.dart';
import 'package:touristai/widgets/preference_slider.dart';
import 'package:touristai/widgets/recommendation_card.dart';

enum _HomeStage { start, preferences, places, loading, recommendations }

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
  int availableMinutes = 60;
  String budget = 'Baixo';
  String transportMode = 'A pe';
  int radiusMeters = 15000;
  UserLocation? currentLocation;
  List<NearbyPlace> nearbyPlaces = const [];
  RecommendationResult? recommendation;
  String? locationError;
  String? placesError;
  String? placesNotice;
  String? recommendationError;
  String? startLocationError;
  bool isLoadingStartLocation = false;
  bool isFindingLocation = false;
  bool isGeneratingRecommendation = false;
  bool hasSearchedPlaces = false;
  _HomeStage stage = _HomeStage.start;

  @override
  void initState() {
    super.initState();
    loadStartLocation();
  }

  Future<void> loadStartLocation() async {
    setState(() {
      isLoadingStartLocation = true;
      startLocationError = null;
    });

    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }

      setState(() {
        currentLocation = location;
      });
    } on LocationFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        startLocationError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        startLocationError = 'Não foi possível carregar sua localização agora.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingStartLocation = false;
        });
      }
    }
  }

  void startNewExploration() {
    setState(() {
      stage = _HomeStage.preferences;
      locationError = null;
      placesError = null;
      placesNotice = null;
      recommendationError = null;
      nearbyPlaces = const [];
      recommendation = null;
      hasSearchedPlaces = false;
    });
  }

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
              'Nenhum local da categoria escolhida foi encontrado em $formattedSearchRadius. Mostrando opções gerais no mesmo raio.';
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
              'Nenhum local da categoria escolhida foi encontrado em 1,5 km. Mostrando opções gerais em até 5 km.';
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
              'Nenhum local próximo foi encontrado em 5 km. Mostrando opções gerais em até 15 km.';
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        nearbyPlaces = places;
        placesNotice = notice;
        hasSearchedPlaces = true;
        stage = _HomeStage.places;
      });
    } on LocationFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        locationError = error.message;
        stage = _HomeStage.preferences;
      });
    } on PlacesFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        placesError = error.message;
        placesNotice = null;
        hasSearchedPlaces = true;
        stage = _HomeStage.places;
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
      stage = _HomeStage.loading;
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
        stage = _HomeStage.recommendations;
      });
    } on RecommendationFailure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        recommendationError = error.message;
        stage = _HomeStage.places;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        recommendationError =
            'Erro de ligação. Verifique se o backend está a ser executado e se o IP configurado está correto.';
        stage = _HomeStage.places;
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
    return radiusMeters;
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
      availableMinutes: availableMinutes,
      budget: switch (budget) {
        'Gratis' => 'gratis',
        'Medio' => 'medio',
        _ => 'baixo',
      },
      transportMode: transportMode == 'Carro' ? 'carro' : 'a_pe',
    );
  }

  String get formattedAvailableTime {
    if (availableMinutes < 60) {
      return '$availableMinutes min';
    }

    final hours = availableMinutes ~/ 60;
    final minutes = availableMinutes % 60;
    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}min';
  }

  String get formattedSearchRadius {
    if (radiusMeters < 1000) {
      return '$radiusMeters m';
    }

    final radiusKm = radiusMeters / 1000;
    if (radiusMeters % 1000 == 0) {
      return '${radiusKm.round()} km';
    }

    return '${radiusKm.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (stage) {
            _HomeStage.start => _buildStartStage(context),
            _HomeStage.preferences => _buildPreferencesStage(context),
            _HomeStage.places => _buildPlacesStage(context),
            _HomeStage.loading => _buildLoadingStage(context),
            _HomeStage.recommendations => _buildRecommendationsStage(context),
          },
        ),
      ),
    );
  }

  Widget _buildStartStage(BuildContext context) {
    final startLocation = currentLocation;

    return Column(
      key: const ValueKey('start-stage'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: _HeaderBar(onBack: null),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: startLocation == null
                    ? _StartLocationStatus(
                        title: _startLocationTitle(),
                        message: startLocationError,
                        isLoading: isLoadingStartLocation,
                      )
                    : _StartLocationMap(location: startLocation),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 190,
                        child: FilledButton.icon(
                          onPressed: startNewExploration,
                          icon: const Icon(Icons.explore),
                          label: const Text('Nova exploração'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _startLocationTitle() {
    if (currentLocation != null) {
      return 'Sua localização atual';
    }
    if (isLoadingStartLocation) {
      return 'Buscando sua localização...';
    }
    return 'Localização não carregada';
  }

  Widget _buildPreferencesStage(BuildContext context) {
    return Column(
      key: const ValueKey('preferences-stage'),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderBar(
                onBack: () => setState(() => stage = _HomeStage.start),
              ),
              const SizedBox(height: 24),
              Text(
                'Personalize seu roteiro',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Conte um pouco sobre suas preferências para criarmos uma experiência perto de você.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
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
              PreferenceSlider(
                label: 'Tempo disponível',
                value: availableMinutes.toDouble(),
                min: 15,
                max: 240,
                displayValue: formattedAvailableTime,
                sliderKey: const ValueKey('available-minutes-slider'),
                onChanged: (value) {
                  setState(() {
                    availableMinutes = value.round();
                  });
                },
              ),
              const SizedBox(height: 12),
              PreferenceDropdown(
                label: 'Orçamento',
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
              PreferenceSlider(
                label: 'Raio de busca',
                value: radiusMeters.toDouble(),
                min: 500,
                max: 30000,
                displayValue: formattedSearchRadius,
                sliderKey: const ValueKey('radius-meters-slider'),
                onChanged: (value) {
                  setState(() {
                    radiusMeters = value.round();
                  });
                },
              ),
              if (locationError != null) ...[
                const SizedBox(height: 12),
                LocationStatusCard(
                  title: 'Não foi possível obter localização',
                  message: locationError!,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: FilledButton.icon(
            onPressed: isFindingLocation ? null : findNearbyPlaces,
            icon: const Icon(Icons.my_location),
            label: Text(
              isFindingLocation
                  ? 'Buscando localização...'
                  : 'Encontrar locais próximos',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesStage(BuildContext context) {
    final location = currentLocation;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('places-stage'),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderBar(
                onBack: () => setState(() => stage = _HomeStage.preferences),
              ),
              const SizedBox(height: 20),
              Text(
                'Locais próximos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Encontramos opções reais com base nas suas preferências.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (location != null) ...[
                LocationStatusCard(
                  title: 'Localização atual',
                  message:
                      'Latitude: ${location.latitude}\nLongitude: ${location.longitude}',
                ),
                const SizedBox(height: 12),
              ],
              if (hasSearchedPlaces)
                PlacesSummaryCard(places: nearbyPlaces, notice: placesNotice),
              if (recommendationError != null) ...[
                const SizedBox(height: 12),
                LocationStatusCard(
                  title: 'Não foi possível gerar roteiro',
                  message: recommendationError!,
                ),
              ],
              if (location != null) ...[
                const SizedBox(height: 12),
                CurrentLocationMap(location: location, places: nearbyPlaces),
              ],
              if (placesError != null) ...[
                const SizedBox(height: 12),
                LocationStatusCard(
                  title: 'Não foi possível buscar locais',
                  message: placesError!,
                ),
              ],
              if (hasSearchedPlaces && nearbyPlaces.isEmpty) ...[
                const SizedBox(height: 12),
                const LocationStatusCard(
                  title: 'Roteiro indisponível',
                  message:
                      'A IA precisa de pelo menos um local encontrado. Tente outra categoria, outra região ou novamente com internet melhor.',
                ),
              ],
            ],
          ),
        ),
        if (nearbyPlaces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: FilledButton.icon(
              onPressed: isGeneratingRecommendation
                  ? null
                  : generateRecommendations,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Gerar roteiro com IA'),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingStage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      key: const ValueKey('loading-stage'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Consultando o TouristAI...',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Analisando locais',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                color: colorScheme.primary,
                backgroundColor: const Color(0xFFE2E2E2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'IA trabalhando...',
              style: TextStyle(color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsStage(BuildContext context) {
    final result = recommendation;

    return Column(
      key: const ValueKey('recommendations-stage'),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HeaderBar(
                onBack: () => setState(() => stage = _HomeStage.places),
              ),
              const SizedBox(height: 20),
              if (result != null) RecommendationCard(result: result),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: FilledButton.icon(
            onPressed: startNewExploration,
            icon: const Icon(Icons.explore),
            label: const Text('Nova exploração'),
          ),
        ),
      ],
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
          )
        else
          Icon(Icons.explore, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'TouristAI',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _StartLocationMap extends StatelessWidget {
  const _StartLocationMap({required this.location});

  final UserLocation location;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final center = LatLng(location.latitude, location.longitude);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'br.edu.touristai',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 46,
                  height: 46,
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
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 12,
          left: 20,
          right: 20,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.my_location,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sua localização atual',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lat: ${location.latitude}\nLong: ${location.longitude}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StartLocationStatus extends StatelessWidget {
  const _StartLocationStatus({
    required this.title,
    required this.message,
    required this.isLoading,
  });

  final String title;
  final String? message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLoading ? Icons.my_location : Icons.location_off,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message ??
                      'O mapa aparecerá aqui assim que o GPS retornar sua posição.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    color: colorScheme.primary,
                    backgroundColor: const Color(0xFFE2E2E2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
