import 'package:geolocator/geolocator.dart';

/// Result wrapper so callers can distinguish "got a position" from
/// "denied" from "service disabled" without throwing raw exceptions.
class LocationResult {
  final Position? position;
  final String? error;

  LocationResult.success(this.position) : error = null;
  LocationResult.failure(this.error) : position = null;

  bool get isSuccess => position != null;
}

class LocationService {
  /// Requests permission (if needed) and returns the current position.
  /// Never throws — always returns a LocationResult so the UI can show
  /// a friendly message instead of crashing on a denied permission.
  static Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
          'Location services are turned off. Please enable GPS.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure(
            'Location permission denied. Enable it to get coordinates.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
          'Location permission permanently denied. Enable it from app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LocationResult.success(position);
    } catch (e) {
      return LocationResult.failure('Could not get location: $e');
    }
  }
}
