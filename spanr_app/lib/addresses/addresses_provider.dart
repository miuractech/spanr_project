import 'package:flutter/material.dart';
import 'models/address.dart';
import 'addresses_service.dart';

class AddressesProvider extends ChangeNotifier {
  final AddressesService _service = AddressesService();
  
  List<Address> _addresses = [];
  Address? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasAddresses => _addresses.isNotEmpty;

  Future<void> loadAddresses(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _service.getAddresses(userId);
      
      // Set default address as selected
      final defaultAddr = _addresses.where((a) => a.isDefault).firstOrNull;
      if (defaultAddr != null) {
        _selectedAddress = defaultAddr;
      } else if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.first;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(Address address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAddress = await _service.createAddress(address);
      _addresses.insert(0, newAddress); // Add to beginning for better UX
      
      // Update default status in local list
      if (newAddress.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          if (_addresses[i].id != newAddress.id) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
        _selectedAddress = newAddress;
      } else if (_selectedAddress == null) {
        _selectedAddress = newAddress;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress(Address address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateAddress(address);
      final index = _addresses.indexWhere((a) => a.id == updated.id);
      
      if (index != -1) {
        _addresses[index] = updated;
        
        // Update default status in local list
        if (updated.isDefault) {
          for (var i = 0; i < _addresses.length; i++) {
            if (_addresses[i].id != updated.id) {
              _addresses[i] = _addresses[i].copyWith(isDefault: false);
            }
          }
        }
        
        if (_selectedAddress?.id == updated.id) {
          _selectedAddress = updated;
        }
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteAddress(addressId);
      _addresses.removeWhere((a) => a.id == addressId);
      
      if (_selectedAddress?.id == addressId) {
        // Try to select default address first, otherwise select first available
        _selectedAddress = _addresses.where((a) => a.isDefault).firstOrNull ??
            (_addresses.isNotEmpty ? _addresses.first : null);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String userId, String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.setDefaultAddress(userId, addressId);
      
      // Update local state
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == addressId,
        );
      }
      
      final defaultAddr = _addresses.where((a) => a.id == addressId).firstOrNull;
      if (defaultAddr != null) {
        _selectedAddress = defaultAddr;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> findAndSetNearestAddress(
    String userId,
    double latitude,
    double longitude,
  ) async {
    if (_addresses.isEmpty) {
      await loadAddresses(userId);
    }

    final nearest = await _service.findNearestAddress(
      userId,
      latitude,
      longitude,
    );

    if (nearest != null) {
      _selectedAddress = nearest;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAddresses() {
    _addresses = [];
    _selectedAddress = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

