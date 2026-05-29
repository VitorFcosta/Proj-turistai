import 'package:geolocator/geolocator.dart';

typedef LocationServiceEnabledGetter = Future<bool> Function();
typedef LocationPermissionGetter = Future<LocationPermission> Function();
typedef CurrentPositionGetter = Future<Position> Function();

class UserLocation {
  const UserLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

enum LocationFailureType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationFailure implements Exception {
  const LocationFailure(this.type, this.message);

  final LocationFailureType type;
  final String message;

  @override
  String toString() => message;
}

class LocationService {
  LocationService({
    LocationServiceEnabledGetter? isLocationServiceEnabled,
    LocationPermissionGetter? checkPermission,
    LocationPermissionGetter? requestPermission,
    CurrentPositionGetter? getCurrentPosition,
  }) : isLocationServiceEnabled =
           isLocationServiceEnabled ?? Geolocator.isLocationServiceEnabled,
       checkPermission = checkPermission ?? Geolocator.checkPermission,
       requestPermission = requestPermission ?? Geolocator.requestPermission,
       getCurrentPosition =
           getCurrentPosition ?? _getCurrentPositionWithHighAccuracy;

  final LocationServiceEnabledGetter isLocationServiceEnabled;
  final LocationPermissionGetter checkPermission;
  final LocationPermissionGetter requestPermission;
  final CurrentPositionGetter getCurrentPosition;

  Future<UserLocation> getCurrentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(
        LocationFailureType.serviceDisabled,
        'Ative a localizacao do celular para encontrar locais proximos.',
      );
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        LocationFailureType.permissionDenied,
        'Permita o acesso a localizacao para usar o TouristAI.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        LocationFailureType.permissionDeniedForever,
        'A permissao de localizacao foi bloqueada. Abra as configuracoes do app.',
      );
    }

    final position = await getCurrentPosition();

    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

Future<Position> _getCurrentPositionWithHighAccuracy() {
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
}
