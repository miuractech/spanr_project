import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../addresses/addresses_provider.dart';
import '../addresses/widgets/address_selector.dart';
import '../core/services/location_service.dart';
import '../mechanics/mechanics_provider.dart';
import '../mechanics/widgets/mechanic_card.dart';
import '../vehicles/screens/vehicles_screen.dart';
import '../booking/orders_screen.dart';
import 'location_permission_screen.dart';

const _orange = Color(0xFFFC8019);
const _bg = Color(0xFFF2F2F2);
const _heading = Color(0xFF1C1C1C);
const _body = Color(0xFF696969);

final _cardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 12,
    offset: const Offset(0, 3),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomePage(),
    const OrdersScreen(),
    const VehiclesScreen(),
    const _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8E8E8), width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: _orange.withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 64,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: _body),
              selectedIcon: Icon(Icons.home, color: _orange),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: _body),
              selectedIcon: Icon(Icons.receipt_long, color: _orange),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined, color: _body),
              selectedIcon: Icon(Icons.directions_car, color: _orange),
              label: 'Vehicles',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: _body),
              selectedIcon: Icon(Icons.person, color: _orange),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final LocationService _locationService = LocationService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _isLocationEnabled = false;
  bool _isCheckingLocation = true;
  bool _isInitialLoading = true;
  bool _skipLocationPermission = false;
  String? _lastSelectedAddressId;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final mechanicsProvider = context.read<MechanicsProvider>();
      if (!mechanicsProvider.isLoading && mechanicsProvider.hasMore) {
        mechanicsProvider.loadMore();
      }
    }
  }

  Future<void> _initializeLocation() async {
    setState(() => _isCheckingLocation = true);

    final permissionGranted = await _locationService.isLocationPermissionGranted();
    final serviceEnabled = await _locationService.isLocationEnabled();

    setState(() {
      _isLocationEnabled = permissionGranted && serviceEnabled;
      _isCheckingLocation = false;
    });

    if (_isLocationEnabled) {
      await _loadAndSetNearestAddress();
    } else {
      await _loadAddressesOnly();
    }

    if (mounted) setState(() => _isInitialLoading = false);
  }

  Future<void> _loadAndSetNearestAddress() async {
    final authProvider = context.read<AuthProvider>();
    final addressProvider = context.read<AddressesProvider>();
    final mechanicsProvider = context.read<MechanicsProvider>();

    if (authProvider.user?.id == null) return;

    final position = await _locationService.getCurrentPosition();
    if (position == null) return;

    await addressProvider.loadAddresses(authProvider.user!.id);

    if (addressProvider.selectedAddress == null) {
      await addressProvider.findAndSetNearestAddress(
        authProvider.user!.id,
        position.latitude,
        position.longitude,
      );
    }

    final selected = addressProvider.selectedAddress;
    mechanicsProvider.loadNearbyMechanics(
      latitude: selected?.latitude ?? position.latitude,
      longitude: selected?.longitude ?? position.longitude,
      refresh: true,
    );
  }

  Future<void> _loadAddressesOnly({bool preserveSelection = false}) async {
    final authProvider = context.read<AuthProvider>();
    final addressProvider = context.read<AddressesProvider>();
    final mechanicsProvider = context.read<MechanicsProvider>();

    if (authProvider.user?.id == null) return;

    await addressProvider.loadAddresses(
      authProvider.user!.id,
      preserveSelection: preserveSelection,
    );

    final selectedAddress = addressProvider.selectedAddress;
    if (selectedAddress != null) {
      mechanicsProvider.loadNearbyMechanics(
        latitude: selectedAddress.latitude,
        longitude: selectedAddress.longitude,
        refresh: true,
      );
    }
  }

  Future<void> _handleRefresh() async {
    final addressProvider = context.read<AddressesProvider>();
    final selectedAddress = addressProvider.selectedAddress;
    if (selectedAddress != null) {
      final mechanicsProvider = context.read<MechanicsProvider>();
      await mechanicsProvider.loadNearbyMechanics(
        latitude: selectedAddress.latitude,
        longitude: selectedAddress.longitude,
        refresh: true,
      );
    } else {
      await _loadAddressesOnly(preserveSelection: true);
    }
  }

  void _handleSkipLocation() {
    setState(() => _skipLocationPermission = true);
    _loadAddressesOnly();
  }

  static const _serviceCategories = [
    ('General Service', Icons.build_outlined, Color(0xFFE3F2FD)),
    ('AC Repair', Icons.ac_unit, Color(0xFFE8F5E9)),
    ('Denting', Icons.car_crash_outlined, Color(0xFFFFF3E0)),
    ('Painting', Icons.format_paint_outlined, Color(0xFFF3E5F5)),
    ('Battery', Icons.battery_charging_full, Color(0xFFFFEBEE)),
    ('Tyre', Icons.tire_repair, Color(0xFFE0F7FA)),
  ];

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressesProvider>();
    final mechanicsProvider = context.watch<MechanicsProvider>();

    final currentAddressId = addressProvider.selectedAddress?.id;
    if (currentAddressId != _lastSelectedAddressId && currentAddressId != null) {
      _lastSelectedAddressId = currentAddressId;
      final selectedAddress = addressProvider.selectedAddress!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mechanicsProvider.loadNearbyMechanics(
            latitude: selectedAddress.latitude,
            longitude: selectedAddress.longitude,
            refresh: true,
          );
        }
      });
    }

    if (!_isCheckingLocation && !_isLocationEnabled && !_skipLocationPermission) {
      return LocationPermissionScreen(
        onPermissionGranted: _initializeLocation,
        onSkip: _handleSkipLocation,
      );
    }

    final showLoading = _isCheckingLocation || _isInitialLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: showLoading
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: _orange),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                color: _orange,
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Location bar
                    Container(
                      color: Colors.white,
                      child: AddressSelector(
                        locationEnabled: _isLocationEnabled,
                        onAddressManage: () async {
                          await context.push('/addresses');
                          if (mounted) {
                            await _loadAddressesOnly(preserveSelection: true);
                          }
                        },
                      ),
                    ),

                    if (!_isLocationEnabled && addressProvider.selectedAddress == null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFE0B2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange.shade700, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Add or select an address to find nearby mechanics',
                                style: TextStyle(color: Color(0xFFE65100), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _cardShadow,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for mechanics, services...',
                            prefixIcon: const Icon(Icons.search,
                                color: _body, size: 22),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            hintStyle:
                                const TextStyle(color: _body, fontSize: 14),
                          ),
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false) _debounce!.cancel();
                            _debounce =
                                Timer(const Duration(milliseconds: 500), () {
                              mechanicsProvider.searchMechanics(value);
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Service categories
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _serviceCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) {
                          final (label, icon, bg) = _serviceCategories[i];
                          return SizedBox(
                            width: 72,
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: _heading, size: 24),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  label,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _heading,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Nearby Mechanics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _heading,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Based on your location',
                            style: TextStyle(fontSize: 13, color: _body),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mechanics list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (mechanicsProvider.mechanics.isEmpty &&
                              !mechanicsProvider.isLoading)
                            _buildEmptyState()
                          else
                            ...mechanicsProvider.mechanics.map(
                              (mechanic) => MechanicCard(
                                mechanic: mechanic,
                                onTap: () => context.push(
                                    '/mechanic/${mechanic.id}',
                                    extra: mechanic),
                              ),
                            ),

                          if (mechanicsProvider.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child:
                                    CircularProgressIndicator(color: _orange),
                              ),
                            ),

                          if (!mechanicsProvider.hasMore &&
                              mechanicsProvider.mechanics.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.location_off_outlined,
                                          size: 28, color: Colors.grey[500]),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'No more results',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'All mechanics within 7km shown',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            const Text(
              'No mechanics found nearby',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try selecting a different address',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();

      if (mounted) {
        context.read<AddressesProvider>().clearAddresses();
        context.read<MechanicsProvider>().clear();
      }

      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: _orange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _orange.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.name[0].toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _heading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(fontSize: 14, color: _body),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user, size: 14, color: _orange),
                            SizedBox(width: 6),
                            Text(
                              'Verified Customer',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _buildSectionLabel('Account'),
                      const SizedBox(height: 8),
                      _buildMenuGroup([
                        _MenuItemData(
                          icon: Icons.person_outline,
                          color: _orange,
                          title: 'Edit Profile',
                          onTap: _isLoggingOut ? null : () {},
                        ),
                        _MenuItemData(
                          icon: Icons.location_on_outlined,
                          color: _orange,
                          title: 'My Addresses',
                          onTap: _isLoggingOut
                              ? null
                              : () => context.push('/addresses'),
                        ),
                        _MenuItemData(
                          icon: Icons.notifications_outlined,
                          color: _orange,
                          title: 'Notifications',
                          onTap: _isLoggingOut ? null : () {},
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Support'),
                      const SizedBox(height: 8),
                      _buildMenuGroup([
                        _MenuItemData(
                          icon: Icons.help_outline,
                          color: _orange,
                          title: 'Help & Support',
                          onTap: _isLoggingOut ? null : () {},
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildMenuGroup([
                        _MenuItemData(
                          icon: Icons.logout,
                          color: Colors.red,
                          title: 'Logout',
                          onTap: _isLoggingOut ? null : _handleLogout,
                          isDestructive: true,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'SPANR v1.0.0',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoggingOut)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: _orange),
                      SizedBox(height: 16),
                      Text('Logging out...',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (i < items.length - 1)
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    final textColor =
        item.isDestructive ? Colors.red.shade600 : _heading;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: item.isDestructive
              ? Colors.red.withOpacity(0.1)
              : item.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon,
            color:
                item.isDestructive ? Colors.red.shade600 : item.color,
            size: 18),
      ),
      title: Text(
        item.title,
        style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500),
      ),
      trailing:
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: item.onTap,
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _MenuItemData({
    required this.icon,
    required this.color,
    required this.title,
    this.onTap,
    this.isDestructive = false,
  });
}
