import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LocationService {
  Future<bool> requestLocationPermission() async {
    final status = await ph.Permission.location.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await ph.Permission.storage.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> requestPhotosPermission() async {
    final status = await ph.Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> isLocationPermissionGranted() async {
    final status = await ph.Permission.location.status;
    return status.isGranted;
  }

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = [
        if (place.street != null && place.street!.isNotEmpty) place.street,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea,
        if (place.postalCode != null && place.postalCode!.isNotEmpty)
          place.postalCode,
      ];

      return parts.join(', ');
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDetailedAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      return {
        'street': place.street ?? '',
        'subLocality': place.subLocality ?? '',
        'locality': place.locality ?? '',
        'subAdministrativeArea': place.subAdministrativeArea ?? '',
        'administrativeArea': place.administrativeArea ?? '',
        'postalCode': place.postalCode ?? '',
        'country': place.country ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      return null;
    }
  }

  Future<void> openLocationSettings() async {
    await ph.openAppSettings();
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }
}

