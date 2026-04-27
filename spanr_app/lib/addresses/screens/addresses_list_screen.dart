import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../addresses_provider.dart';
import '../models/address.dart';
import '../../auth/auth_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/services/places_service.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PlacesService _placesService = PlacesService();
  final LocationService _locationService = LocationService();

  List<PlacePrediction> _suggestions = [];
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.autocomplete(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _loadAddresses() async {
    final authProvider = context.read<AuthProvider>();
    final addressProvider = context.read<AddressesProvider>();
    if (authProvider.user?.id != null) {
      await addressProvider.loadAddresses(authProvider.user!.id);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
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
        final prefill = Address(
          userId: '',
          label: '',
          addressLine1: details?['street'] ?? '',
          city: details?['locality'] ?? '',
          state: details?['administrativeArea'] ?? '',
          postalCode: details?['postalCode'] ?? '',
          country: details?['country'] ?? '',
          latitude: position.latitude,
          longitude: position.longitude,
        );
        final result =
            await context.push<bool>('/addresses/add', extra: prefill);
        if (result == true) _loadAddresses();
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _onSuggestionTapped(PlacePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    final details = await _placesService.getPlaceDetails(prediction.placeId);
    if (mounted) {
      setState(() {
        _isSearching = false;
        _suggestions = [];
        _searchController.clear();
      });

      if (details != null) {
        final prefill = Address(
          userId: '',
          label: '',
          addressLine1: details.street,
          city: details.city,
          state: details.state,
          postalCode: details.postalCode,
          country: details.country,
          latitude: details.latitude,
          longitude: details.longitude,
        );
        final result =
            await context.push<bool>('/addresses/add', extra: prefill);
        if (result == true) _loadAddresses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressesProvider>();
    final isTyping = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Your Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(isTyping),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (isTyping && _suggestions.isNotEmpty)
            Expanded(child: _buildSuggestions())
          else if (isTyping && !_isSearching)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
            )
          else
            Expanded(
              child: addressProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      children: [
                        _buildCurrentLocationOption(),
                        const SizedBox(height: 24),
                        ...addressProvider.addresses
                            .map((address) => _AddressListItem(
                                  address: address,
                                  onTap: () {
                                    addressProvider.selectAddress(address);
                                    Navigator.of(context).pop();
                                  },
                                  onEdit: () async {
                                    final result =
                                        await context.push<bool>(
                                      '/addresses/edit',
                                      extra: address,
                                    );
                                    if (result == true) _loadAddresses();
                                  },
                                  onDelete: () async {
                                    if (address.id == null) return;
                                    final confirmed =
                                        await _showDeleteConfirmation(context);
                                    if (confirmed == true) {
                                      await addressProvider
                                          .deleteAddress(address.id!);
                                    }
                                  },
                                )),
                        if (addressProvider.addresses.isEmpty)
                          _buildEmptyState(),
                      ],
                    ),
            ),
          if (!isTyping) _buildSkipButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isTyping) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          Icon(Icons.search, color: Colors.grey[500], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for area, street name...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (isTyping)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              },
              child: Icon(Icons.close, color: Colors.grey[500], size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey[200], height: 1),
      itemBuilder: (context, index) {
        final p = _suggestions[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on_outlined,
                size: 20, color: Colors.grey),
          ),
          title: Text(
            p.mainText,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: p.secondaryText.isNotEmpty
              ? Text(
                  p.secondaryText,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                )
              : null,
          onTap: () => _onSuggestionTapped(p),
        );
      },
    );
  }

  Widget _buildCurrentLocationOption() {
    return InkWell(
      onTap: _isLoadingLocation ? null : _useCurrentLocation,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: _isLoadingLocation
                  ? CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.red[600])
                  : Icon(Icons.gps_fixed, color: Colors.red[600], size: 24),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Using GPS',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Skip',
          style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No saved addresses\nSearch or use current location to add one',
          style: TextStyle(fontSize: 15, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content:
            const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddressListItem extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressListItem({
    required this.address,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getIconForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('home')) return Icons.home_outlined;
    if (l.contains('office') || l.contains('work'))
      return Icons.business_outlined;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showOptionsBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getIconForLabel(address.label),
                color: Colors.grey[700], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[600], height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Address'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Address',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
