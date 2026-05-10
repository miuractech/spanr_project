import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../core/services/location_service.dart';
import '../core/theme/app_theme.dart';

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
    
    await _updateStatus('Setting up location...');
    await Future.delayed(const Duration(milliseconds: 300));
    await _locationService.requestLocationPermission();

    await _updateStatus('Setting up storage...');
    await Future.delayed(const Duration(milliseconds: 300));
    
    await _locationService.requestStoragePermission();
    await _locationService.requestPhotosPermission();

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
          backgroundColor: AppTheme.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E9DF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.build_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'SPANR',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textHeading,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Mechanic On Demand',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textBody,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      backgroundColor: AppTheme.bgLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryOrange,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textBody,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}
