import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/services/location_service.dart';

const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

class LocationPermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback? onSkip;

  const LocationPermissionScreen({
    super.key,
    required this.onPermissionGranted,
    this.onSkip,
  });

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndProceedIfReady();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndProceedIfReady();
    }
  }

  Future<void> _checkAndProceedIfReady() async {
    final granted = await _locationService.isLocationPermissionGranted();
    if (!granted) return;
    final enabled = await _locationService.isLocationEnabled();
    if (!enabled) return;
    if (mounted) {
      widget.onPermissionGranted();
    }
  }

  Future<void> _handleEnableLocation() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      final permissionStatus = await Permission.location.request();

      if (permissionStatus.isPermanentlyDenied) {
        if (mounted) _showSettingsDialog(context);
        return;
      }

      if (!permissionStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please allow location permission to continue')),
          );
        }
        return;
      }

      final serviceEnabled = await _locationService.isLocationEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        final nowEnabled = await _locationService.isLocationEnabled();
        if (!nowEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please turn on device location service')),
            );
          }
          return;
        }
      }

      await _checkAndProceedIfReady();
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: _kOrange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 56,
                      color: _kOrange,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Location Permission',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _kHeading,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enable location to find nearby mechanics automatically, or add your address manually.',
                    style: TextStyle(fontSize: 15, color: _kBody, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        _StepItem(
                          number: 1,
                          title: 'Tap "Enable Location"',
                          description: 'Tap the button below to grant permission',
                        ),
                        SizedBox(height: 18),
                        _StepItem(
                          number: 2,
                          title: 'Allow Location Access',
                          description: 'Select "While using the app" or "Always"',
                        ),
                        SizedBox(height: 18),
                        _StepItem(
                          number: 3,
                          title: 'Start Booking',
                          description: 'Find mechanics and book services near you',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isRequesting ? null : _handleEnableLocation,
                      icon: _isRequesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.location_on, size: 20),
                      label: Text(
                        _isRequesting ? 'Checking...' : 'Enable Location',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _kOrange.withValues(alpha: 0.5),
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.onSkip != null)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _isRequesting ? null : widget.onSkip,
                        icon: const Icon(Icons.edit_location_alt, size: 20),
                        label: const Text(
                          'Use Manual Address',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kOrange,
                          side: const BorderSide(color: _kOrange, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showSettingsDialog(context),
                    child: const Text(
                      'Open App Settings',
                      style: TextStyle(
                        color: _kBody,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Open Settings',
          style: TextStyle(color: _kHeading, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Location permission is denied. Please enable it from app settings.',
          style: TextStyle(color: _kBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: _kBody)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: _kOrange,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: _kHeading,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: _kBody,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
