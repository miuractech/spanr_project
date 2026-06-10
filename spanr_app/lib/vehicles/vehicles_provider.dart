import 'dart:io';
import 'package:flutter/foundation.dart';
import 'models/vehicle_model.dart';
import 'vehicles_service.dart';

class VehiclesProvider with ChangeNotifier {
  final VehiclesService _service = VehiclesService();
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVehicles(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _service.getVehiclesByUser(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    try {
      final newVehicle = await _service.createVehicle(vehicle);
      _vehicles.insert(0, newVehicle);
      notifyListeners();
      return newVehicle;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateVehicle(
      String vehicleId, Map<String, dynamic> updates) async {
    try {
      final updated = await _service.updateVehicle(vehicleId, updates);
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasLinkedOrders(String vehicleId) async {
    return _service.hasLinkedOrders(vehicleId);
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _service.deleteVehicle(vehicleId);
      _vehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(String vehicleId, File imageFile) async {
    try {
      final imageUrl = await _service.uploadImage(vehicleId, imageFile);
      
      // Update local vehicle with new image
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = _vehicles[index].copyWith(
          images: [..._vehicles[index].images, imageUrl],
        );
        notifyListeners();
      }
      
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImage(String vehicleId, String imageUrl) async {
    try {
      await _service.deleteImage(vehicleId, imageUrl);
      
      // Update local vehicle by removing image
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        final updatedImages = _vehicles[index].images
            .where((url) => url != imageUrl)
            .toList();
        _vehicles[index] = _vehicles[index].copyWith(images: updatedImages);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}

