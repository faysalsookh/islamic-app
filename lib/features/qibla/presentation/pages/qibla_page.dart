import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/qibla_calculator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/compass_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../widgets/qibla_compass_widget.dart';
import '../widgets/compass_theme_selector.dart';
import '../widgets/compass_calibration_dialog.dart';

/// State of the Qibla page
enum QiblaPageState {
  loading,
  ready,
  noLocation,
  noCompass,
  error,
}

/// Qibla status for user feedback
enum QiblaStatus {
  searching,
  almostThere,
  facingMecca,
  notFacing,
}

/// Main Qibla direction page with professional compass
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
  double? _sunBearing;
  CompassAccuracy _accuracy = CompassAccuracy.unknown;
  CompassTheme _selectedTheme = CompassTheme.golden;

  StreamSubscription<double>? _headingSubscription;
  StreamSubscription<CompassAccuracy>? _accuracySubscription;

  bool _showedCalibrationHint = false;
  QiblaStatus _lastStatus = QiblaStatus.searching;

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
      if (_pageState == QiblaPageState.noLocation ||
          _pageState == QiblaPageState.error) {
        _initialize();
      }
    }
  }

  /// Get current Qibla status
  QiblaStatus get _qiblaStatus {
    if (_pageState != QiblaPageState.ready) return QiblaStatus.searching;

    final qiblaDirection = (_qiblaBearing - _heading + 360) % 360;

    if (qiblaDirection <= 5 || qiblaDirection >= 355) {
      return QiblaStatus.facingMecca;
    } else if (qiblaDirection <= 20 || qiblaDirection >= 340) {
      return QiblaStatus.almostThere;
    }
    return QiblaStatus.notFacing;
  }

  Future<void> _initialize() async {
    setState(() {
      _pageState = QiblaPageState.loading;
      _errorMessage = null;
    });

    final locationResult = await _locationService.getCurrentPosition();

    if (locationResult.result != LocationResult.success) {
      setState(() {
        _pageState = QiblaPageState.noLocation;
        _errorMessage = locationResult.message;
      });
      return;
    }

    _position = locationResult.position;

    _qiblaBearing = QiblaCalculator.calculateQiblaBearing(
      _position!.latitude,
      _position!.longitude,
    );

    _distanceKm = QiblaCalculator.calculateDistanceToKaaba(
      _position!.latitude,
      _position!.longitude,
    );

    // Calculate approximate sun position for user reference
    // Formula: (Hour-12)*15 + 180. noon=180(South), 6am=90(East), 6pm=270(West)
    final now = DateTime.now();
    _sunBearing = ((now.hour + now.minute / 60.0 - 12.0) * 15.0 + 180.0) % 360;

    final compassAvailable = await CompassService.isCompassAvailable();

    if (!compassAvailable) {
      setState(() {
        _pageState = QiblaPageState.noCompass;
        _errorMessage = 'Compass sensor is not available on this device.';
      });
      return;
    }

    _compassService.startListening();

    _headingSubscription = _compassService.headingStream.listen((heading) {
      if (mounted) {
        setState(() {
          _heading = heading;
        });

        // Haptic feedback when facing Qibla
        final currentStatus = _qiblaStatus;
        if (currentStatus == QiblaStatus.facingMecca && _lastStatus != QiblaStatus.facingMecca) {
          HapticService().mediumImpact();
        }
        _lastStatus = currentStatus;
      }
    });

    _accuracySubscription = _compassService.accuracyStream.listen((accuracy) {
      if (mounted) {
        setState(() {
          _accuracy = accuracy;
        });

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text('Compass accuracy is low')),
          ],
        ),
        action: SnackBarAction(
          label: 'Calibrate',
          textColor: Colors.amber,
          onPressed: () => CompassCalibrationDialog.show(context),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF333333),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: _buildBody(context, isTablet),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isTablet) {
    switch (_pageState) {
      case QiblaPageState.loading:
        return _buildLoadingState(isTablet);
      case QiblaPageState.noLocation:
        return _buildNoLocationState(isTablet);
      case QiblaPageState.noCompass:
        return _buildNoCompassState(isTablet);
      case QiblaPageState.error:
        return _buildErrorState(isTablet);
      case QiblaPageState.ready:
        return _buildReadyState(isTablet);
    }
  }

  Widget _buildLoadingState(bool isTablet) {
    return Column(
      children: [
        _buildAppBar(isTablet),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4A853),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Finding your location...',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoLocationState(bool isTablet) {
    return Column(
      children: [
        _buildAppBar(isTablet),
        Expanded(
          child: _buildStateMessage(
            icon: Icons.location_off_rounded,
            iconColor: Colors.amber,
            title: 'Location Required',
            message: _errorMessage ?? 'Please enable location services to find Qibla direction.',
            buttonLabel: 'Enable Location',
            onButtonPressed: _handleLocationAction,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildNoCompassState(bool isTablet) {
    return Column(
      children: [
        _buildAppBar(isTablet),
        Expanded(
          child: _buildStateMessage(
            icon: Icons.explore_off_rounded,
            iconColor: Colors.red,
            title: 'Compass Not Available',
            message: _errorMessage ?? 'Your device does not have a compass sensor.',
            buttonLabel: null,
            onButtonPressed: null,
            isTablet: isTablet,
            additionalWidget: _position != null ? _buildStaticBearingInfo(isTablet) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isTablet) {
    return Column(
      children: [
        _buildAppBar(isTablet),
        Expanded(
          child: _buildStateMessage(
            icon: Icons.error_outline_rounded,
            iconColor: Colors.red,
            title: 'Something Went Wrong',
            message: _errorMessage ?? 'An error occurred. Please try again.',
            buttonLabel: 'Retry',
            onButtonPressed: _initialize,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title with Qibla bearing
          Expanded(
            child: Text(
              _pageState == QiblaPageState.ready
                  ? 'Qibla: ${_qiblaBearing.round()}°'
                  : 'Qibla Direction',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Refresh button
          if (_pageState == QiblaPageState.ready)
            GestureDetector(
              onTap: () {
                HapticService().lightImpact();
                _initialize();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String? buttonLabel,
    required VoidCallback? onButtonPressed,
    required bool isTablet,
    Widget? additionalWidget,
  }) {
    return Center(
      child: SingleChildScrollView(
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
              child: Icon(icon, size: isTablet ? 48 : 40, color: iconColor),
            ),
            SizedBox(height: isTablet ? 32 : 24),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              SizedBox(height: isTablet ? 32 : 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A853),
                  foregroundColor: Colors.black,
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

  Widget _buildStaticBearingInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Qibla Direction',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.navigation_rounded,
                color: const Color(0xFF4CAF50),
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${QiblaCalculator.formatBearing(_qiblaBearing)} ${QiblaCalculator.getCardinalDirection(_qiblaBearing)}',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Use a physical compass to find this direction',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyState(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isCompact = availableHeight < 600;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _buildAppBar(isTablet),

                  // Compass area - takes remaining space
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 48 : 16,
                          vertical: isCompact ? 8 : 16,
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Compass widget
                            QiblaCompassWidget(
                              heading: _heading,
                              qiblaBearing: _qiblaBearing,
                              sunBearing: _sunBearing,
                              isTablet: isTablet,
                              theme: _selectedTheme,
                            ),

                            SizedBox(height: isCompact ? 16 : 24),

                            // Status message
                            _buildStatusMessage(isTablet),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Info section
                  _buildInfoSection(isTablet),

                  // Theme selector
                  _buildThemeSection(isTablet),

                  SizedBox(height: isTablet ? 20 : 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage(bool isTablet) {
    final status = _qiblaStatus;
    String message;
    Color color;
    IconData? icon;

    switch (status) {
      case QiblaStatus.facingMecca:
        message = "You're now facing Mecca";
        color = const Color(0xFF4CAF50);
        icon = Icons.check_circle_rounded;
        break;
      case QiblaStatus.almostThere:
        message = 'Almost there';
        color = const Color(0xFFD4A853);
        icon = null;
        break;
      case QiblaStatus.notFacing:
        message = 'Turn to find Qibla';
        color = Colors.white60;
        icon = null;
        break;
      case QiblaStatus.searching:
        message = 'Searching...';
        color = Colors.white60;
        icon = null;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(status), // Use enum as key instead of string
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: status == QiblaStatus.facingMecca
              ? Border.all(color: color.withValues(alpha: 0.5), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: isTablet ? 22 : 20),
              SizedBox(width: isTablet ? 10 : 8),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Distance to Kaaba
          Expanded(
            child: _buildInfoItem(
              icon: Icons.place_rounded,
              label: 'Distance',
              value: QiblaCalculator.formatDistance(_distanceKm),
              color: const Color(0xFFE57373),
              isTablet: isTablet,
            ),
          ),
          Container(
            width: 1,
            height: isTablet ? 45 : 35,
            color: Colors.white12,
          ),
          // Qibla bearing
          Expanded(
            child: _buildInfoItem(
              icon: Icons.navigation_rounded,
              label: 'Bearing',
              value: '${_qiblaBearing.round()}° ${QiblaCalculator.getCardinalDirection(_qiblaBearing)}',
              color: const Color(0xFF4CAF50),
              isTablet: isTablet,
            ),
          ),
          Container(
            width: 1,
            height: isTablet ? 45 : 35,
            color: Colors.white12,
          ),
          // Accuracy
          Expanded(
            child: _buildInfoItem(
              icon: Icons.gps_fixed_rounded,
              label: 'Accuracy',
              value: _getAccuracyText(),
              color: Color(CompassService.getAccuracyColorValue(_accuracy)),
              isTablet: isTablet,
              onTap: _compassService.needsCalibration()
                  ? () => CompassCalibrationDialog.show(context)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getAccuracyText() {
    switch (_accuracy) {
      case CompassAccuracy.high:
        return 'High';
      case CompassAccuracy.medium:
        return 'Medium';
      case CompassAccuracy.low:
        return 'Low';
      case CompassAccuracy.unreliable:
        return 'Poor';
      case CompassAccuracy.unknown:
        return '...';
    }
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isTablet,
    VoidCallback? onTap,
  }) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: isTablet ? 22 : 18),
        SizedBox(height: isTablet ? 6 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 11 : 9,
            color: Colors.white54,
          ),
        ),
        SizedBox(height: isTablet ? 2 : 1),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 13 : 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  Widget _buildThemeSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
          child: Text(
            'Compass Style',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: isTablet ? 8 : 6),
        CompassThemeSelector(
          selectedTheme: _selectedTheme,
          onThemeChanged: (theme) {
            setState(() {
              _selectedTheme = theme;
            });
          },
          isTablet: isTablet,
        ),
      ],
    );
  }
}
