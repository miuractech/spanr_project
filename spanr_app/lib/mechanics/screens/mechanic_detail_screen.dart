import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/mechanic_company.dart';
import '../models/service_model.dart';
import '../models/plan_model.dart';
import '../services_plans_service.dart';
import '../widgets/plan_card.dart';
import '../../cart/cart_provider.dart';
import '../../core/services/location_service.dart';

const _kPrimaryOrange = Color(0xFFFC8019);
const _kRatingGreen = Color(0xFF267E3E);
const _kBg = Color(0xFFF2F2F2);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);

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
  int _currentImagePage = 0;
  final Set<String> _expandedServices = {};

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
      final services = await _service.getServicesByCompany(widget.company.id);

      final Map<String, List<PlanModel>> servicePlans = {};
      for (final service in services) {
        final plans = await _service.getPlansByService(service.id);
        if (plans.isNotEmpty) {
          servicePlans[service.id] = plans;
        }
      }

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

      if (!mounted) return;

      // Auto-expand all services that have plans
      final expanded = <String>{};
      for (final s in services) {
        if (servicePlans.containsKey(s.id)) expanded.add(s.id);
      }

      setState(() {
        _services = services;
        _servicePlans = servicePlans;
        _companyWithDistance = companyWithDistance;
        _expandedServices.addAll(expanded);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
      backgroundColor: _kBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _kPrimaryOrange))
          : _error != null
              ? _buildError()
              : Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(company),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCompanyHeader(company),
                              _buildDividerThick(),
                              _buildServicesSection(cartProvider, company),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!cartProvider.isEmpty)
                      _buildFloatingCartButton(cartProvider),
                  ],
                ),
    );
  }

  // --------------- Error ---------------
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error',
              style: const TextStyle(color: _kBody, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // --------------- SliverAppBar with carousel ---------------
  Widget _buildSliverAppBar(MechanicCompany company) {
    final hasImages = company.images != null && company.images!.isNotEmpty;
    final imageCount = hasImages ? company.images!.length : 0;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: _kHeading,
      leading: _circleBackButton(),
      flexibleSpace: FlexibleSpaceBar(
        background: hasImages
            ? Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: imageCount,
                    onPageChanged: (i) =>
                        setState(() => _currentImagePage = i),
                    itemBuilder: (context, index) {
                      return Image.network(
                        company.images![index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _companyHeroBrandFallback(company),
                      );
                    },
                  ),
                  // Page indicator
                  if (imageCount > 1)
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentImagePage + 1}/$imageCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              )
            : _companyHeroBrandFallback(company),
      ),
    );
  }

  Widget _companyHeroBrandFallback(MechanicCompany company) {
    final url = company.logo;
    return Container(
      color: const Color(0xFFE0E0E0),
      alignment: Alignment.center,
      child: url != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.business,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            )
          : const Icon(Icons.business, size: 80, color: Colors.grey),
    );
  }

  Widget _circleBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kHeading, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  // --------------- Company Header ---------------
  Widget _buildCompanyHeader(MechanicCompany company) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Text(
            company.companyName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kHeading,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Rating badge + distance
          Row(
            children: [
              _ratingBadge(company),
              if (company.distanceKm != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.near_me, size: 14, color: _kBody),
                const SizedBox(width: 4),
                Text(company.displayDistance,
                    style: const TextStyle(
                        fontSize: 13,
                        color: _kBody,
                        fontWeight: FontWeight.w500)),
              ],
            ],
          ),

          // Detailed rating breakdown
          if (company.rating != null && company.ratingsCount != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRatingItem(
                          'Overall', company.rating!, Icons.star),
                      _buildRatingItem(
                          'Quality', company.quality ?? 0, Icons.verified),
                      _buildRatingItem('Timeliness', company.timeliness ?? 0,
                          Icons.access_time),
                      _buildRatingItem('Professional',
                          company.professionalism ?? 0, Icons.business_center),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${company.ratingsCount} ratings',
                    style:
                        const TextStyle(color: _kBody, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ratingBadge(MechanicCompany company) {
    final hasRating = company.rating != null && company.rating! > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasRating ? _kRatingGreen : Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            company.displayRating,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --------------- Thick Divider ---------------
  Widget _buildDividerThick() {
    return const SizedBox(height: 8, child: ColoredBox(color: _kBg));
  }

  // --------------- Services & Plans ---------------
  Widget _buildServicesSection(
      CartProvider cartProvider, MechanicCompany company) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Menu" style header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _kPrimaryOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Services & Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_services.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No services available',
                    style: TextStyle(color: _kBody, fontSize: 14)),
              ),
            )
          else
            ..._services.map((service) {
              final plans = _servicePlans[service.id] ?? [];
              if (plans.isEmpty) return const SizedBox.shrink();
              final isExpanded = _expandedServices.contains(service.id);

              return Column(
                children: [
                  // Category header – tappable
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedServices.remove(service.id);
                        } else {
                          _expandedServices.add(service.id);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          if (service.iconUrl != null)
                            Image.network(
                              service.iconUrl!,
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.build_outlined,
                                  size: 20,
                                  color: _kHeading),
                            )
                          else
                            const Icon(Icons.build_outlined,
                                size: 20, color: _kHeading),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kHeading,
                              ),
                            ),
                          ),
                          Text(
                            '${plans.length} ${plans.length == 1 ? 'plan' : 'plans'}',
                            style: const TextStyle(
                                fontSize: 11, color: _kBody),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.keyboard_arrow_down,
                                size: 20, color: _kBody),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (service.description != null && isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 30),
                      child: Text(
                        service.description!,
                        style:
                            const TextStyle(color: _kBody, fontSize: 12),
                      ),
                    ),

                  // Plans
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 8),
                      child: Column(
                        children: plans.map((plan) {
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
                                  backgroundColor: _kRatingGreen,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    MediaQuery.of(context).padding.bottom + 86,
                                  ),
                                ),
                              );
                            },
                            onRemoveFromCart: () {
                              cartProvider.removePlan(plan.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${plan.name} removed from cart'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    MediaQuery.of(context).padding.bottom + 86,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                ],
              );
            }),
        ],
      ),
    );
  }

  // --------------- Floating Cart Button ---------------
  Widget _buildFloatingCartButton(CartProvider cartProvider) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 12,
      child: GestureDetector(
        onTap: _proceedToVehicleSelection,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: _kPrimaryOrange,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _kPrimaryOrange.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Item count badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'ITEM' : 'ITEMS'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Continue  •  ₹${cartProvider.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --------------- Rating Item (kept from original) ---------------
  Widget _buildRatingItem(String label, double rating, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: _kPrimaryOrange),
        const SizedBox(height: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _kHeading,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: _kBody),
        ),
      ],
    );
  }
}
