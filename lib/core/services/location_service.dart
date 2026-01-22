import 'package:geolocator/geolocator.dart';

/// Result types for location operations
enum LocationResult {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

/// Service for handling GPS location with permission management
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastKnownPosition;

  /// Get the last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get current position with full error handling
  /// Returns a record with result type and optional position
  Future<({LocationResult result, Position? position, String? message})> getCurrentPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return (
        result: LocationResult.serviceDisabled,
        position: null,
        message: 'Location services are disabled. Please enable them in settings.',
      );
    }

    // Check permission status
    var permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return (
          result: LocationResult.permissionDenied,
          position: null,
          message: 'Location permission was denied. Please grant permission to use the Qibla compass.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return (
        result: LocationResult.permissionDeniedForever,
        position: null,
        message: 'Location permission is permanently denied. Please enable it in app settings.',
      );
    }

    // Get position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _lastKnownPosition = position;
      return (
        result: LocationResult.success,
        position: position,
        message: null,
      );
    } catch (e) {
      // Try to get last known position as fallback
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _lastKnownPosition = lastPosition;
          return (
            result: LocationResult.success,
            position: lastPosition,
            message: 'Using last known location.',
          );
        }
      } catch (_) {}

      return (
        result: LocationResult.error,
        position: null,
        message: 'Unable to get your location. Please try again.',
      );
    }
  }

  /// Get position stream for real-time updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
