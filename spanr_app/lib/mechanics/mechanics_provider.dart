import 'package:flutter/material.dart';
import 'models/mechanic_company.dart';
import 'mechanics_service.dart';

class MechanicsProvider extends ChangeNotifier {
  final MechanicsService _service = MechanicsService();

  List<MechanicCompany> _mechanics = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  
  double? _lastLatitude;
  double? _lastLongitude;
  String? _lastSearchQuery;
  int _offset = 0;

  List<MechanicCompany> get mechanics => _mechanics;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadNearbyMechanics({
    required double latitude,
    required double longitude,
    String? searchQuery,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _mechanics = [];
      _offset = 0;
      _hasMore = true;
    }

    _lastLatitude = latitude;
    _lastLongitude = longitude;
    _lastSearchQuery = searchQuery;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMechanics = await _service.getNearbyMechanics(
        latitude: latitude,
        longitude: longitude,
        searchQuery: searchQuery,
        limit: 10,
        offset: _offset,
      );

      if (newMechanics.isEmpty || newMechanics.length < 10) {
        _hasMore = false;
      }

      _mechanics.addAll(newMechanics);
      _offset += newMechanics.length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_lastLatitude != null && _lastLongitude != null && _hasMore) {
      await loadNearbyMechanics(
        latitude: _lastLatitude!,
        longitude: _lastLongitude!,
        searchQuery: _lastSearchQuery,
      );
    }
  }
  
  void searchMechanics(String query) {
    if (_lastLatitude != null && _lastLongitude != null) {
      loadNearbyMechanics(
        latitude: _lastLatitude!,
        longitude: _lastLongitude!,
        searchQuery: query.isEmpty ? null : query,
        refresh: true,
      );
    }
  }

  void clear() {
    _mechanics = [];
    _offset = 0;
    _hasMore = true;
    _error = null;
    _lastLatitude = null;
    _lastLongitude = null;
    _lastSearchQuery = null;
    notifyListeners();
  }
}

