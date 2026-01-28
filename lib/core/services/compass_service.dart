import 'dart:async';
import 'dart:math' as _math;
import 'package:flutter_compass/flutter_compass.dart';

/// Compass accuracy levels
enum CompassAccuracy {
  high,
  medium,
  low,
  unreliable,
  unknown,
}

/// Service for handling compass sensor with calibration detection
class CompassService {
  static final CompassService _instance = CompassService._internal();
  factory CompassService() => _instance;
  CompassService._internal();

  StreamSubscription<CompassEvent>? _compassSubscription;
  final _headingController = StreamController<double>.broadcast();
  final _accuracyController = StreamController<CompassAccuracy>.broadcast();

  double? _lastHeading;
  CompassAccuracy _currentAccuracy = CompassAccuracy.unknown;

  /// Stream of heading values (in degrees, 0-360)
  Stream<double> get headingStream => _headingController.stream;

  /// Stream of accuracy changes
  Stream<CompassAccuracy> get accuracyStream => _accuracyController.stream;

  /// Current heading value
  double? get currentHeading => _lastHeading;

  /// Current accuracy level
  CompassAccuracy get currentAccuracy => _currentAccuracy;

  /// Check if compass is available on this device
  static Future<bool> isCompassAvailable() async {
    final events = await FlutterCompass.events?.first;
    return events != null;
  }

  /// Start listening to compass updates
  void startListening() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        if (event.heading != null) {
          // Apply low-pass filter using vector smoothing
          // This prevents the "wrap-around" issue at 0/360 degrees
          
          double currentHeading = event.heading!;
          
          if (_lastHeading != null) {
            // Convert to radians
            final currentRad = currentHeading * (3.14159265359 / 180);
            final lastRad = _lastHeading! * (3.14159265359 / 180);
            
            // Convert to vectors
            final currentX = _math.cos(currentRad);
            final currentY = _math.sin(currentRad);
            
            final lastX = _math.cos(lastRad);
            final lastY = _math.sin(lastRad);
            
            // Smooth factor (0.1 = very smooth/slow, 0.9 = very responsive/jittery)
            const double alpha = 0.15;
            
            final newX = lastX + alpha * (currentX - lastX);
            final newY = lastY + alpha * (currentY - lastY);
            
            // Convert back to angle
            double newRad = _math.atan2(newY, newX);
            double newHeading = newRad * (180 / 3.14159265359);
            
            // Normalize to 0-360
            newHeading = (newHeading + 360) % 360;
            
            _lastHeading = newHeading;
          } else {
            _lastHeading = currentHeading;
          }
          
          _headingController.add(_lastHeading!);

          // Determine accuracy from heading accuracy if available
          final accuracy = _determineAccuracy(event.accuracy);
          if (accuracy != _currentAccuracy) {
            _currentAccuracy = accuracy;
            _accuracyController.add(accuracy);
          }
        }
      },
      onError: (error) {
        _currentAccuracy = CompassAccuracy.unreliable;
        _accuracyController.add(CompassAccuracy.unreliable);
      },
    );
  }

  /// Stop listening to compass updates
  void stopListening() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  /// Determine accuracy level from heading accuracy value
  CompassAccuracy _determineAccuracy(double? accuracy) {
    if (accuracy == null) return CompassAccuracy.unknown;

    // Accuracy is the angular accuracy in degrees
    // Lower values mean higher accuracy
    if (accuracy <= 5) return CompassAccuracy.high;
    if (accuracy <= 15) return CompassAccuracy.medium;
    if (accuracy <= 30) return CompassAccuracy.low;
    return CompassAccuracy.unreliable;
  }

  /// Get accuracy description for display
  static String getAccuracyDescription(CompassAccuracy accuracy) {
    switch (accuracy) {
      case CompassAccuracy.high:
        return 'High accuracy';
      case CompassAccuracy.medium:
        return 'Medium accuracy';
      case CompassAccuracy.low:
        return 'Low accuracy - calibration recommended';
      case CompassAccuracy.unreliable:
        return 'Unreliable - please calibrate';
      case CompassAccuracy.unknown:
        return 'Checking accuracy...';
    }
  }

  /// Get accuracy color for UI
  static int getAccuracyColorValue(CompassAccuracy accuracy) {
    switch (accuracy) {
      case CompassAccuracy.high:
        return 0xFF4CAF50; // Green
      case CompassAccuracy.medium:
        return 0xFFFFB74D; // Amber
      case CompassAccuracy.low:
        return 0xFFFF9800; // Orange
      case CompassAccuracy.unreliable:
        return 0xFFE57373; // Red
      case CompassAccuracy.unknown:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Check if calibration is needed
  bool needsCalibration() {
    return _currentAccuracy == CompassAccuracy.low ||
           _currentAccuracy == CompassAccuracy.unreliable;
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _headingController.close();
    _accuracyController.close();
  }
}
