import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../addresses_provider.dart';
import '../models/address.dart';
import '../../auth/auth_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/services/places_service.dart';

const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

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
      final hasPermission = await _locationService.isLocationPermissionGranted();
      if (!hasPermission) {
        final status = await Permission.location.request();
        if (status.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Location permission permanently denied'),
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: _kOrange,
                  onPressed: () => _locationService.openLocationSettings(),
                ),
              ),
            );
          }
          return;
        }
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Location permission denied'),
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: _kOrange,
                  onPressed: () => _locationService.openLocationSettings(),
                ),
              ),
            );
          }
          return;
        }
      }

      final serviceEnabled = await _locationService.isLocationEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        final nowEnabled = await _locationService.isLocationEnabled();
        if (!nowEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please turn on location service (GPS)')),
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
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kHeading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Your Location',
          style: TextStyle(
            color: _kHeading,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(isTyping),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5),
            )
          else if (isTyping && _suggestions.isNotEmpty)
            Expanded(child: _buildSuggestions())
          else if (isTyping && !_isSearching)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No results found',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: addressProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      children: [
                        _buildCurrentLocationOption(),
                        const SizedBox(height: 16),
                        if (addressProvider.addresses.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'SAVED ADDRESSES',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[500],
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ...addressProvider.addresses
                            .map((address) => _AddressListItem(
                                  address: address,
                                  onTap: () {
                                    addressProvider.selectAddress(address);
                                    Navigator.of(context).pop();
                                  },
                                  onEdit: () async {
                                    final result = await context.push<bool>(
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
                        if (addressProvider.addresses.isEmpty) _buildEmptyState(),
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
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        cursorColor: _kOrange,
        decoration: InputDecoration(
          hintText: 'Search for area, street name...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
          suffixIcon: isTyping
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: Icon(Icons.close, color: Colors.grey[400], size: 20),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kOrange, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_outlined, size: 20, color: _kOrange),
          ),
          title: Text(
            p.mainText,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _kHeading),
          ),
          subtitle: p.secondaryText.isNotEmpty
              ? Text(
                  p.secondaryText,
                  style: const TextStyle(fontSize: 13, color: _kBody),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child: _isLoadingLocation
                    ? const CircularProgressIndicator(
                        strokeWidth: 2, color: _kOrange)
                    : const Icon(Icons.gps_fixed, color: _kOrange, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _kOrange,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Using GPS',
                  style: TextStyle(fontSize: 13, color: _kBody),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: _kOrange, size: 24),
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
        child: const Text(
          'Skip',
          style: TextStyle(
            fontSize: 15,
            color: _kBody,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.location_off_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No saved addresses',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Search or use current location to add one',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address',
            style: TextStyle(color: _kHeading, fontWeight: FontWeight.w700)),
        content: const Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(color: _kBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: _kBody)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
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
    if (l.contains('office') || l.contains('work')) return Icons.business_outlined;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showOptionsBottomSheet(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getIconForLabel(address.label),
                  color: _kBody, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _kHeading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _kBody,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: _kBody, size: 20),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: _kOrange, size: 18),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: _kOrange),
              title: const Text('Edit Address'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete Address',
                  style: TextStyle(color: Colors.redAccent)),
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
