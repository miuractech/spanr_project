import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../addresses_provider.dart';
import '../models/address.dart';
import '../widgets/location_map_view.dart';
import '../../auth/auth_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/services/places_service.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? address;

  const AddressFormScreen({super.key, this.address});

  bool get isEditing => address?.id != null;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationService = LocationService();
  final _placesService = PlacesService();

  late final TextEditingController _searchController;
  late final TextEditingController _labelController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;

  double? _latitude;
  double? _longitude;
  bool _isDefault = false;
  bool _isLoading = false;
  bool _isFetchingLocation = false;
  bool _isInitializingLocation = false;

  List<PlacePrediction> _suggestions = [];
  bool _isSearchLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _searchController = TextEditingController();
    _labelController = TextEditingController(text: a?.label ?? '');
    _addressLine1Controller =
        TextEditingController(text: a?.addressLine1 ?? '');
    _addressLine2Controller =
        TextEditingController(text: a?.addressLine2 ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _stateController = TextEditingController(text: a?.state ?? '');
    _postalCodeController =
        TextEditingController(text: a?.postalCode ?? '');
    _countryController = TextEditingController(text: a?.country ?? '');
    _latitude = a?.latitude;
    _longitude = a?.longitude;
    _isDefault = a?.isDefault ?? false;

    if (_latitude == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _initCurrentLocation());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _labelController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _initCurrentLocation() async {
    setState(() => _isInitializingLocation = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted && _latitude == null) {
        final details =
            await _locationService.getDetailedAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            if (details != null) {
              _addressLine1Controller.text = details['street'] ?? '';
              _cityController.text = details['locality'] ?? '';
              _stateController.text = details['administrativeArea'] ?? '';
              _postalCodeController.text = details['postalCode'] ?? '';
              _countryController.text = details['country'] ?? '';
            }
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isInitializingLocation = false);
    }
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearchLoading = false;
      });
      return;
    }
    setState(() {
      _showSuggestions = true;
      _isSearchLoading = true;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.autocomplete(value);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearchLoading = false;
        });
      }
    });
  }

  Future<void> _onSuggestionTapped(PlacePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() => _isSearchLoading = true);

    final details = await _placesService.getPlaceDetails(prediction.placeId);
    if (mounted) {
      setState(() {
        _isSearchLoading = false;
        _showSuggestions = false;
        _suggestions = [];
        _searchController.clear();
        if (details != null) {
          _addressLine1Controller.text = details.street;
          _cityController.text = details.city;
          _stateController.text = details.state;
          _postalCodeController.text = details.postalCode;
          _countryController.text = details.country;
          _latitude = details.latitude;
          _longitude = details.longitude;
        }
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final hasPermission =
          await _locationService.isLocationPermissionGranted();
      if (!hasPermission) {
        final granted = await _locationService.requestLocationPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Location permission denied'),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () => _locationService.openLocationSettings(),
                ),
              ),
            );
          }
          return;
        }
      }

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get current location')),
          );
        }
        return;
      }

      final details = await _locationService.getDetailedAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          if (details != null) {
            _addressLine1Controller.text = details['street'] ?? '';
            _cityController.text = details['locality'] ?? '';
            _stateController.text = details['administrativeArea'] ?? '';
            _postalCodeController.text = details['postalCode'] ?? '';
            _countryController.text = details['country'] ?? '';
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _onMarkerMoved(double lat, double lng) async {
    setState(() {
      _latitude = lat;
      _longitude = lng;
    });
    final details =
        await _locationService.getDetailedAddressFromCoordinates(lat, lng);
    if (mounted && details != null) {
      setState(() {
        if (details['street']?.isNotEmpty == true) {
          _addressLine1Controller.text = details['street']!;
        }
        if (details['locality']?.isNotEmpty == true) {
          _cityController.text = details['locality']!;
        }
        if (details['administrativeArea']?.isNotEmpty == true) {
          _stateController.text = details['administrativeArea']!;
        }
        if (details['postalCode']?.isNotEmpty == true) {
          _postalCodeController.text = details['postalCode']!;
        }
        if (details['country']?.isNotEmpty == true) {
          _countryController.text = details['country']!;
        }
      });
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please set a location by searching or using GPS')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final addressProvider = context.read<AddressesProvider>();
      if (authProvider.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final address = widget.isEditing
          ? widget.address!.copyWith(
              label: _labelController.text,
              addressLine1: _addressLine1Controller.text,
              addressLine2: _addressLine2Controller.text.isEmpty
                  ? null
                  : _addressLine2Controller.text,
              city: _cityController.text,
              state: _stateController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
              latitude: _latitude!,
              longitude: _longitude!,
              isDefault: _isDefault,
              updatedAt: DateTime.now(),
            )
          : Address.create(
              userId: authProvider.user!.id,
              label: _labelController.text,
              addressLine1: _addressLine1Controller.text,
              addressLine2: _addressLine2Controller.text.isEmpty
                  ? null
                  : _addressLine2Controller.text,
              city: _cityController.text,
              state: _stateController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
              latitude: _latitude!,
              longitude: _longitude!,
              isDefault: _isDefault,
            );

      if (widget.isEditing) {
        await addressProvider.updateAddress(address);
      } else {
        await addressProvider.addAddress(address);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Address' : 'Add Address'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showSuggestions)
            Expanded(child: _buildSuggestionsList())
          else
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMapSection(),
                    const SizedBox(height: 16),
                    _buildFormFields(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16)),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.isEditing
                              ? 'Update Address'
                              : 'Save Address'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[500], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_isSearchLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _suggestions = [];
                  _showSuggestions = false;
                });
                FocusScope.of(context).unfocus();
              },
              child: Icon(Icons.close, color: Colors.grey[500], size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (_isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_suggestions.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey[200], height: 1),
      itemBuilder: (context, index) {
        final p = _suggestions[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on_outlined,
                size: 20, color: Colors.grey),
          ),
          title: Text(p.mainText,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: p.secondaryText.isNotEmpty
              ? Text(p.secondaryText,
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey[600]))
              : null,
          onTap: () => _onSuggestionTapped(p),
        );
      },
    );
  }

  Widget _buildMapSection() {
    if (_isInitializingLocation) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Getting your location...'),
            ],
          ),
        ),
      );
    }

    if (_latitude == null || _longitude == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Column(
          children: [
            Icon(Icons.location_on, size: 48, color: Colors.blue[400]),
            const SizedBox(height: 12),
            const Text(
              'Set your service location',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Search above or tap below to use your current location',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isFetchingLocation ? null : _useCurrentLocation,
              icon: _isFetchingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 16),
              label: const Text('Use Current Location'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        LocationMapView(
          latitude: _latitude,
          longitude: _longitude,
          onLocationChanged: _onMarkerMoved,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Drag pin to adjust exact location',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            TextButton.icon(
              onPressed: _isFetchingLocation ? null : _useCurrentLocation,
              icon: _isFetchingLocation
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 14),
              label: const Text('Reset to GPS', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _labelController,
          decoration: const InputDecoration(
            labelText: 'Label',
            hintText: 'e.g., Home, Work, Office',
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please enter a label' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressLine1Controller,
          decoration: const InputDecoration(
            labelText: 'Address Line 1',
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please enter address' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressLine2Controller,
          decoration: const InputDecoration(
            labelText: 'Address Line 2 (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                    labelText: 'City', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                    labelText: 'State', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                    labelText: 'Postal Code', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                    labelText: 'Country', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Set as default address'),
          value: _isDefault,
          onChanged: (v) => setState(() => _isDefault = v),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
