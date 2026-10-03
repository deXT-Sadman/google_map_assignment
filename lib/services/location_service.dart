import 'package:geolocator/geolocator.dart';

/// Thrown when the current location cannot be obtained.
class LocationException implements Exception {
  final String message;
  final bool openAppSettings;
  final bool openLocationSettings;

  LocationException(
    this.message, {
    this.openAppSettings = false,
    this.openLocationSettings = false,
  });

  @override
  String toString() => message;
}

class LocationService {
  /// Checks service + permission, then returns the device's real position.
  /// Never hard-coded: it always comes from the device's location service.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Location services are turned off. Please enable GPS.',
        openLocationSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location permission is permanently denied. Enable it from app settings.',
        openAppSettings: true,
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  Future<bool> hasPermission() async {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
