import 'dart:math';

/// Service for calculating Qibla direction and distance to Kaaba
class QiblaCalculator {
  // Kaaba coordinates in Mecca, Saudi Arabia
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla bearing from given location using forward azimuth formula
  /// Returns bearing in degrees (0-360) where 0 is North
  static double calculateQiblaBearing(double latitude, double longitude) {
    // Convert to radians
    final lat1 = _toRadians(latitude);
    final lon1 = _toRadians(longitude);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    // Calculate difference in longitude
    final deltaLon = lon2 - lon1;

    // Forward azimuth formula
    final x = sin(deltaLon) * cos(lat2);
    final y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);

    // Calculate bearing in radians
    var bearing = atan2(x, y);

    // Convert to degrees
    bearing = _toDegrees(bearing);

    // Normalize to 0-360
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// Calculate distance to Kaaba in kilometers using Haversine formula
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    const earthRadiusKm = 6371.0;

    final lat1 = _toRadians(latitude);
    final lon1 = _toRadians(longitude);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    final deltaLat = lat2 - lat1;
    final deltaLon = lon2 - lon1;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Format distance for display (km or m)
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else if (distanceKm < 100) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km';
    }
  }

  /// Format bearing for display
  static String formatBearing(double bearing) {
    return '${bearing.round()}°';
  }

  /// Get cardinal direction from bearing
  static String getCardinalDirection(double bearing) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Get full direction name
  static String getFullDirectionName(double bearing) {
    final cardinal = getCardinalDirection(bearing);
    switch (cardinal) {
      case 'N': return 'North';
      case 'NNE': return 'North-Northeast';
      case 'NE': return 'Northeast';
      case 'ENE': return 'East-Northeast';
      case 'E': return 'East';
      case 'ESE': return 'East-Southeast';
      case 'SE': return 'Southeast';
      case 'SSE': return 'South-Southeast';
      case 'S': return 'South';
      case 'SSW': return 'South-Southwest';
      case 'SW': return 'Southwest';
      case 'WSW': return 'West-Southwest';
      case 'W': return 'West';
      case 'WNW': return 'West-Northwest';
      case 'NW': return 'Northwest';
      case 'NNW': return 'North-Northwest';
      default: return cardinal;
    }
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
