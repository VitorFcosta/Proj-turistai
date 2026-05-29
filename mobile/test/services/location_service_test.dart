import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touristai/services/location_service.dart';

void main() {
  test('returns current location when permission is already allowed', () async {
    final service = LocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.whileInUse,
      requestPermission: () async {
        throw StateError('Permission should not be requested');
      },
      getCurrentPosition: () async =>
          _position(latitude: -23.55052, longitude: -46.633308),
    );

    final location = await service.getCurrentLocation();

    expect(location.latitude, -23.55052);
    expect(location.longitude, -46.633308);
  });

  test('throws serviceDisabled when location service is off', () async {
    final service = LocationService(
      isLocationServiceEnabled: () async => false,
      checkPermission: () async => LocationPermission.whileInUse,
      requestPermission: () async => LocationPermission.whileInUse,
      getCurrentPosition: () async =>
          _position(latitude: -23.55052, longitude: -46.633308),
    );

    expect(
      service.getCurrentLocation,
      throwsA(
        isA<LocationFailure>().having(
          (failure) => failure.type,
          'type',
          LocationFailureType.serviceDisabled,
        ),
      ),
    );
  });

  test(
    'throws permissionDeniedForever when permission cannot be requested',
    () async {
      final service = LocationService(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.deniedForever,
        requestPermission: () async => LocationPermission.deniedForever,
        getCurrentPosition: () async =>
            _position(latitude: -23.55052, longitude: -46.633308),
      );

      expect(
        service.getCurrentLocation,
        throwsA(
          isA<LocationFailure>().having(
            (failure) => failure.type,
            'type',
            LocationFailureType.permissionDeniedForever,
          ),
        ),
      );
    },
  );
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
