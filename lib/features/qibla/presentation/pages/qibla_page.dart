import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/qibla_calculator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/compass_service.dart';
import '../widgets/qibla_compass_widget.dart';
import '../widgets/qibla_info_card.dart';
import '../widgets/compass_calibration_dialog.dart';

/// State of the Qibla page
enum QiblaPageState {
  loading,
  ready,
  noLocation,
  noCompass,
  error,
}

/// Main Qibla direction page with compass
class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  final CompassService _compassService = CompassService();

  QiblaPageState _pageState = QiblaPageState.loading;
  String? _errorMessage;

  Position? _position;
  double _heading = 0;
  double _qiblaBearing = 0;
  double _distanceKm = 0;
  CompassAccuracy _accuracy = CompassAccuracy.unknown;

  StreamSubscription<double>? _headingSubscription;
  StreamSubscription<CompassAccuracy>? _accuracySubscription;

  bool _showedCalibrationHint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _headingSubscription?.cancel();
    _accuracySubscription?.cancel();
    _compassService.stopListening();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check location and compass when app returns to foreground
      if (_pageState == QiblaPageState.noLocation ||
          _pageState == QiblaPageState.error) {
        _initialize();
      }
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _pageState = QiblaPageState.loading;
      _errorMessage = null;
    });

    // Get location first
    final locationResult = await _locationService.getCurrentPosition();

    if (locationResult.result != LocationResult.success) {
      setState(() {
        _pageState = QiblaPageState.noLocation;
        _errorMessage = locationResult.message;
      });
      return;
    }

    _position = locationResult.position;

    // Calculate Qibla bearing
    _qiblaBearing = QiblaCalculator.calculateQiblaBearing(
      _position!.latitude,
      _position!.longitude,
    );

    _distanceKm = QiblaCalculator.calculateDistanceToKaaba(
      _position!.latitude,
      _position!.longitude,
    );

    // Check compass availability
    final compassAvailable = await CompassService.isCompassAvailable();

    if (!compassAvailable) {
      setState(() {
        _pageState = QiblaPageState.noCompass;
        _errorMessage = 'Compass sensor is not available on this device.';
      });
      return;
    }

    // Start compass
    _compassService.startListening();

    _headingSubscription = _compassService.headingStream.listen((heading) {
      if (mounted) {
        setState(() {
          _heading = heading;
        });
      }
    });

    _accuracySubscription = _compassService.accuracyStream.listen((accuracy) {
      if (mounted) {
        setState(() {
          _accuracy = accuracy;
        });

        // Show calibration hint if accuracy is low (only once per session)
        if (!_showedCalibrationHint && _compassService.needsCalibration()) {
          _showedCalibrationHint = true;
          _showCalibrationSnackbar();
        }
      }
    });

    setState(() {
      _pageState = QiblaPageState.ready;
    });
  }

  void _showCalibrationSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Compass accuracy is low. Tap to calibrate.'),
        action: SnackBarAction(
          label: 'Calibrate',
          onPressed: () => CompassCalibrationDialog.show(context),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLocationAction() async {
    final result = await _locationService.getCurrentPosition();

    if (result.result == LocationResult.serviceDisabled) {
      await _locationService.openLocationSettings();
    } else if (result.result == LocationResult.permissionDeniedForever) {
      await _locationService.openAppSettings();
    } else {
      _initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      appBar: AppBar(
        title: Text(
          'Qibla Direction',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        actions: [
          if (_pageState == QiblaPageState.ready)
            IconButton(
              onPressed: () => CompassCalibrationDialog.show(context),
              icon: const Icon(Icons.help_outline_rounded),
              tooltip: 'Calibration help',
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context, isDark, isTablet),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, bool isTablet) {
    switch (_pageState) {
      case QiblaPageState.loading:
        return _buildLoadingState(isDark);
      case QiblaPageState.noLocation:
        return _buildNoLocationState(isDark, isTablet);
      case QiblaPageState.noCompass:
        return _buildNoCompassState(isDark, isTablet);
      case QiblaPageState.error:
        return _buildErrorState(isDark, isTablet);
      case QiblaPageState.ready:
        return _buildReadyState(isDark, isTablet);
    }
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.forestGreen,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Finding your location...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLocationState(bool isDark, bool isTablet) {
    return _buildStateMessage(
      icon: Icons.location_off_rounded,
      iconColor: AppColors.warning,
      title: 'Location Required',
      message: _errorMessage ?? 'Please enable location services to find Qibla direction.',
      buttonLabel: 'Enable Location',
      onButtonPressed: _handleLocationAction,
      isDark: isDark,
      isTablet: isTablet,
    );
  }

  Widget _buildNoCompassState(bool isDark, bool isTablet) {
    return _buildStateMessage(
      icon: Icons.explore_off_rounded,
      iconColor: AppColors.error,
      title: 'Compass Not Available',
      message: _errorMessage ?? 'Your device does not have a compass sensor.',
      buttonLabel: null,
      onButtonPressed: null,
      isDark: isDark,
      isTablet: isTablet,
      additionalWidget: _buildStaticBearingInfo(isDark, isTablet),
    );
  }

  Widget _buildErrorState(bool isDark, bool isTablet) {
    return _buildStateMessage(
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      title: 'Something Went Wrong',
      message: _errorMessage ?? 'An error occurred. Please try again.',
      buttonLabel: 'Retry',
      onButtonPressed: _initialize,
      isDark: isDark,
      isTablet: isTablet,
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String? buttonLabel,
    required VoidCallback? onButtonPressed,
    required bool isDark,
    required bool isTablet,
    Widget? additionalWidget,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isTablet ? 48 : 40,
                color: iconColor,
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              SizedBox(height: isTablet ? 32 : 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 32,
                    vertical: isTablet ? 16 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (additionalWidget != null) ...[
              SizedBox(height: isTablet ? 40 : 32),
              additionalWidget,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStaticBearingInfo(bool isDark, bool isTablet) {
    if (_position == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Qibla Direction',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.navigation_rounded,
                color: AppColors.forestGreen,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${QiblaCalculator.formatBearing(_qiblaBearing)} ${QiblaCalculator.getCardinalDirection(_qiblaBearing)}',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Use a physical compass to find this direction',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyState(bool isDark, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48 : 20,
        vertical: isTablet ? 32 : 20,
      ),
      child: Column(
        children: [
          // Compass widget
          Center(
            child: QiblaCompassWidget(
              heading: _heading,
              qiblaBearing: _qiblaBearing,
              isTablet: isTablet,
            ),
          ),

          SizedBox(height: isTablet ? 40 : 28),

          // Instruction text
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 14 : 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: isTablet ? 20 : 18,
                  color: AppColors.forestGreen,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Flexible(
                  child: Text(
                    'Point your phone towards the mosque icon to face Qibla',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: AppColors.forestGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Info card
          QiblaInfoCard(
            qiblaBearing: _qiblaBearing,
            distanceKm: _distanceKm,
            accuracy: _accuracy,
            isTablet: isTablet,
            onCalibrateTap: () => CompassCalibrationDialog.show(context),
          ),

          SizedBox(height: isTablet ? 24 : 16),

          // Location info
          _buildLocationInfo(isDark, isTablet),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(bool isDark, bool isTablet) {
    if (_position == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.my_location_rounded,
            size: isTablet ? 18 : 16,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          SizedBox(width: isTablet ? 10 : 8),
          Text(
            'Your location: ${_position!.latitude.toStringAsFixed(4)}°, ${_position!.longitude.toStringAsFixed(4)}°',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          GestureDetector(
            onTap: _initialize,
            child: Icon(
              Icons.refresh_rounded,
              size: isTablet ? 18 : 16,
              color: AppColors.forestGreen,
            ),
          ),
        ],
      ),
    );
  }
}
