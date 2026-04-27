import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../core/services/location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocationService _locationService = LocationService();
  String _statusMessage = 'Initializing...';
  bool _hasNavigated = false;
  bool _isInitializing = false;

  Future<void> _initializeApp() async {
    if (_hasNavigated || _isInitializing) return;
    _isInitializing = true;
    
    // Request location permission
    await _updateStatus('Setting up location...');
    await Future.delayed(const Duration(milliseconds: 300));
    await _locationService.requestLocationPermission();

    // Request storage permission
    await _updateStatus('Setting up storage...');
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Try both storage and photos for better compatibility
    await _locationService.requestStoragePermission();
    await _locationService.requestPhotosPermission();

    // Complete initialization
    await _updateStatus('Loading your experience...');
    await Future.delayed(const Duration(milliseconds: 300));

    _navigateTo('/home');
  }

  void _navigateTo(String path) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    context.go(path);
  }

  Future<void> _updateStatus(String message) async {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!_hasNavigated && !authProvider.isLoading) {
          Future.delayed(Duration.zero, () {
            if (!mounted || _hasNavigated) return;
            if (!authProvider.isAuthenticated) {
              _navigateTo('/login');
            } else {
              _initializeApp();
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.build_circle,
                    size: 80,
                    color: Color(0xFFFF5722),
                  ),
                ),
                const SizedBox(height: 32),
                
                // App Name
                const Text(
                  'SPANR',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Your Mechanic On Demand',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 64),
                
                // Progress Indicator
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF5722),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Status Message
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
