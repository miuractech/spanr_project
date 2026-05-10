import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/plan_model.dart';

const _kOrange = Color(0xFFFC8019);
const _kGreen = Color(0xFF267E3E);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);

class PlanDetailsDialog extends StatefulWidget {
  final PlanModel plan;
  final String serviceName;
  final List<String>? images;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const PlanDetailsDialog({
    super.key,
    required this.plan,
    required this.serviceName,
    this.images,
    required this.isInCart,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  static void show(
    BuildContext context, {
    required PlanModel plan,
    required String serviceName,
    List<String>? images,
    required bool isInCart,
    required VoidCallback onAddToCart,
    required VoidCallback onRemoveFromCart,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlanDetailsDialog(
        plan: plan,
        serviceName: serviceName,
        images: images,
        isInCart: isInCart,
        onAddToCart: onAddToCart,
        onRemoveFromCart: onRemoveFromCart,
      ),
    );
  }

  @override
  State<PlanDetailsDialog> createState() => _PlanDetailsDialogState();
}

class _PlanDetailsDialogState extends State<PlanDetailsDialog> {
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if ((widget.images?.length ?? 0) > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final count = widget.images!.length;
      final next = (_currentPage + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (images.isNotEmpty)
                      _buildImageCarousel(images)
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: _kOrange.withValues(alpha: 0.06),
                        ),
                        child: Center(
                          child: Icon(Icons.build_circle_outlined,
                              size: 64, color: _kOrange.withValues(alpha: 0.4)),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.plan.badge != null)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _kOrange,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          widget.plan.badge!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      widget.plan.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: _kHeading,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.serviceName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: _kBody,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.close, size: 20, color: _kBody),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _kOrange.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: _kOrange.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Base Price',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${widget.plan.basePrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: _kOrange,
                                        ),
                                      ),
                                      Text(
                                        '+${widget.plan.tax.toStringAsFixed(0)}% tax',
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    width: 1,
                                    height: 52,
                                    color: _kOrange.withValues(alpha: 0.2)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total (incl. tax)',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${widget.plan.totalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: _kOrange,
                                        ),
                                      ),
                                      Text(
                                        'Final amount',
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildDetailGrid(),

                          if (widget.plan.fuelTypes.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildSectionTitle('Fuel Types'),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: widget.plan.fuelTypes
                                  .map(
                                    (fuel) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: _kOrange.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: _kOrange.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        fuel.toUpperCase(),
                                        style: const TextStyle(
                                          color: _kOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],

                          if (widget.plan.warranty != null ||
                              widget.plan.guarantee != null) ...[
                            const SizedBox(height: 20),
                            _buildSectionTitle('Assurance'),
                            const SizedBox(height: 10),
                            if (widget.plan.warranty != null)
                              _buildAssuranceRow(
                                Icons.verified_user,
                                'Warranty',
                                widget.plan.warranty!,
                                _kOrange,
                                _kOrange.withValues(alpha: 0.08),
                              ),
                            if (widget.plan.guarantee != null)
                              _buildAssuranceRow(
                                Icons.shield,
                                'Guarantee',
                                widget.plan.guarantee!,
                                _kGreen,
                                _kGreen.withValues(alpha: 0.08),
                              ),
                          ],

                          if (widget.plan.features.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildSectionTitle("What's Included"),
                            const SizedBox(height: 12),
                            ...widget.plan.features.map(
                              (feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: _kGreen.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check,
                                          size: 12, color: _kGreen),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: _kBody,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    '₹${widget.plan.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _kOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.isInCart) {
                    widget.onRemoveFromCart();
                  } else {
                    widget.onAddToCart();
                  }
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  widget.isInCart
                      ? Icons.remove_shopping_cart
                      : Icons.add_shopping_cart,
                  size: 18,
                ),
                label: Text(
                  widget.isInCart ? 'Remove' : 'Add to Cart',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.isInCart ? Colors.grey.shade600 : _kOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: images.length,
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kOrange)),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported,
                    color: Colors.grey, size: 48),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _kOrange
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _kHeading,
      ),
    );
  }

  Widget _buildDetailGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time,
                  'Duration',
                  widget.plan.durationDisplay,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.directions_car,
                  'Vehicle',
                  widget.plan.vehicleType.toUpperCase(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.location_on,
                  'Location',
                  widget.plan.locationType == 'in_premise'
                      ? 'In Premise'
                      : 'Shed',
                ),
              ),
              if (widget.plan.fuelTypes.isNotEmpty)
                Expanded(
                  child: _buildDetailItem(
                    Icons.local_gas_station,
                    'Fuel Types',
                    '${widget.plan.fuelTypes.length} supported',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: _kOrange),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _kHeading)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssuranceRow(
    IconData icon,
    String label,
    String value,
    Color color,
    Color bgColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
