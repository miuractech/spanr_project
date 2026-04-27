import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/mechanic_company.dart';
import '../models/service_model.dart';
import '../models/plan_model.dart';
import '../services_plans_service.dart';
import '../widgets/plan_card.dart';
import '../../cart/cart_provider.dart';
import '../../core/services/location_service.dart';

class MechanicDetailScreen extends StatefulWidget {
  final MechanicCompany company;

  const MechanicDetailScreen({
    super.key,
    required this.company,
  });

  @override
  State<MechanicDetailScreen> createState() => _MechanicDetailScreenState();
}

class _MechanicDetailScreenState extends State<MechanicDetailScreen> {
  final ServicesPlanService _service = ServicesPlanService();
  final LocationService _locationService = LocationService();
  
  List<ServiceModel> _services = [];
  Map<String, List<PlanModel>> _servicePlans = {};
  bool _isLoading = true;
  String? _error;
  MechanicCompany? _companyWithDistance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load services for this company
      final services = await _service.getServicesByCompany(widget.company.id);
      
      // Load plans for each service
      final Map<String, List<PlanModel>> servicePlans = {};
      for (final service in services) {
        final plans = await _service.getPlansByService(service.id);
        if (plans.isNotEmpty) {
          servicePlans[service.id] = plans;
        }
      }

      // Calculate distance if location is available
      MechanicCompany? companyWithDistance = widget.company;
      if (widget.company.latitude != null && widget.company.longitude != null) {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          final distance = _locationService.calculateDistance(
            position.latitude,
            position.longitude,
            widget.company.latitude!,
            widget.company.longitude!,
          );
          companyWithDistance = widget.company.copyWith(distanceKm: distance);
        }
      }

      setState(() {
        _services = services;
        _servicePlans = servicePlans;
        _companyWithDistance = companyWithDistance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }

  void _proceedToVehicleSelection() {
    final cartProvider = context.read<CartProvider>();
    
    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one plan to cart')),
      );
      return;
    }

    context.push('/select-vehicle', extra: widget.company);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final company = _companyWithDistance ?? widget.company;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // App Bar with Images
                    SliverAppBar(
                      expandedHeight: 250,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: company.images != null && company.images!.isNotEmpty
                            ? PageView.builder(
                                itemCount: company.images!.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    company.images![index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.business,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company Header
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (company.logo != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          company.logo!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.business),
                                            );
                                          },
                                        ),
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            company.companyName,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF424242),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (company.distanceKm != null)
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  company.displayDistance,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Ratings
                                if (company.rating != null && company.ratingsCount != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildRatingItem(
                                              'Overall',
                                              company.rating!,
                                              Icons.star,
                                            ),
                                            _buildRatingItem(
                                              'Quality',
                                              company.quality ?? 0,
                                              Icons.verified,
                                            ),
                                            _buildRatingItem(
                                              'Timeliness',
                                              company.timeliness ?? 0,
                                              Icons.access_time,
                                            ),
                                            _buildRatingItem(
                                              'Professional',
                                              company.professionalism ?? 0,
                                              Icons.business_center,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${company.ratingsCount} ratings',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                const SizedBox(height: 16),
                                
                                // Contact Info
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _makePhoneCall(company.phone),
                                        icon: const Icon(Icons.phone),
                                        label: const Text('Call'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _openEmail(company.email),
                                        icon: const Icon(Icons.email),
                                        label: const Text('Email'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                
                                // Address
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        company.fullAddress,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
                          
                          // Services & Plans
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Services & Plans',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                if (_services.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Text(
                                        'No services available',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                else
                                  ..._services.map((service) {
                                    final plans = _servicePlans[service.id] ?? [];
                                    if (plans.isEmpty) return const SizedBox.shrink();
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (service.iconUrl != null)
                                              Image.network(
                                                service.iconUrl!,
                                                width: 24,
                                                height: 24,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.build,
                                                    size: 24,
                                                  );
                                                },
                                              )
                                            else
                                              const Icon(Icons.build, size: 24),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                service.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF424242),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        if (service.description != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            service.description!,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                        
                                        const SizedBox(height: 12),
                                        
                                        ...plans.map((plan) {
                                          final isInCart = cartProvider.isPlanInCart(plan.id);
                                          return PlanCard(
                                            plan: plan,
                                            serviceName: service.name,
                                            images: company.images,
                                            isInCart: isInCart,
                                            onAddToCart: () {
                                              cartProvider.addPlan(
                                                plan,
                                                service.name,
                                                company.id,
                                                company.companyName,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${plan.name} added to cart'),
                                                  duration: const Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                            onRemoveFromCart: () {
                                              cartProvider.removePlan(plan.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${plan.name} removed from cart'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                        
                                        const SizedBox(height: 24),
                                      ],
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                          
                          // Bottom padding for floating button
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
      
      // Floating Cart Button
      floatingActionButton: cartProvider.isEmpty
          ? null
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FloatingActionButton.extended(
                onPressed: _proceedToVehicleSelection,
                backgroundColor: Theme.of(context).colorScheme.primary,
                icon: Badge(
                  label: Text('${cartProvider.itemCount}'),
                  child: const Icon(Icons.shopping_cart),
                ),
                label: Text(
                  'Continue • ₹${cartProvider.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRatingItem(String label, double rating, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.amber.shade700),
        const SizedBox(height: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade900,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

