import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:touristai/services/location_service.dart';
import 'package:touristai/services/places_service.dart';

class UserPreferences {
  const UserPreferences({
    required this.category,
    required this.availableMinutes,
    required this.budget,
    required this.transportMode,
  });

  final String category;
  final int availableMinutes;
  final String budget;
  final String transportMode;
}

class RecommendationResult {
  const RecommendationResult({
    required this.title,
    required this.summary,
    required this.recommendations,
    required this.generalTip,
  });

  final String title;
  final String summary;
  final List<PlaceRecommendation> recommendations;
  final String generalTip;
}

class PlaceRecommendation {
  const PlaceRecommendation({
    required this.placeId,
    required this.placeName,
    required this.suggestedOrder,
    required this.reason,
    required this.tip,
  });

  final String placeId;
  final String placeName;
  final int suggestedOrder;
  final String reason;
  final String tip;
}

class RecommendationFailure implements Exception {
  const RecommendationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class RecommendationService {
  RecommendationService({http.Client? client, String? baseUrl})
    : client = client ?? http.Client(),
      baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'TOURISTAI_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  final http.Client client;
  final String baseUrl;

  Future<RecommendationResult> generateRecommendations({
    required UserLocation location,
    required int radiusMeters,
    required UserPreferences preferences,
    required List<NearbyPlace> places,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/recommendations'),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'radiusMeters': radiusMeters,
        },
        'preferences': {
          'category': preferences.category,
          'availableMinutes': preferences.availableMinutes,
          'budget': preferences.budget,
          'transportMode': preferences.transportMode,
        },
        'places': places.map(_placeToJson).toList(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const RecommendationFailure(
        'Nao foi possivel gerar o roteiro agora.',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const RecommendationFailure('Resposta invalida da API.');
    }

    return _parseRecommendationResult(payload);
  }

  Map<String, Object> _placeToJson(NearbyPlace place) {
    return {
      'id': place.id,
      'name': place.name,
      'type': place.type,
      'latitude': place.latitude,
      'longitude': place.longitude,
      'distanceMeters': place.distanceMeters,
    };
  }

  RecommendationResult _parseRecommendationResult(Map<String, dynamic> json) {
    final recommendations = json['recommendations'];
    if (recommendations is! List<dynamic>) {
      throw const RecommendationFailure('Resposta invalida da API.');
    }

    return RecommendationResult(
      title: _readString(json, 'title'),
      summary: _readString(json, 'summary'),
      generalTip: _readString(json, 'generalTip'),
      recommendations: recommendations
          .whereType<Map<String, dynamic>>()
          .map(_parsePlaceRecommendation)
          .toList(),
    );
  }

  PlaceRecommendation _parsePlaceRecommendation(Map<String, dynamic> json) {
    return PlaceRecommendation(
      placeId: _readString(json, 'placeId'),
      placeName: _readString(json, 'placeName'),
      suggestedOrder: _readInt(json, 'suggestedOrder'),
      reason: _readString(json, 'reason'),
      tip: _readString(json, 'tip'),
    );
  }

  String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }

    throw const RecommendationFailure('Resposta invalida da API.');
  }

  int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }

    throw const RecommendationFailure('Resposta invalida da API.');
  }
}
