import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/auth_provider.dart';
import 'order_provider.dart';
import 'order_types.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    if (authProvider.user != null) {
      await orderProvider.loadUserOrders(authProvider.user!.id);
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return const Color(0xFF2196F3);
      case OrderStatus.accepted:
        return const Color(0xFF4CAF50);
      case OrderStatus.inProgress:
        return const Color(0xFFFF9800);
      case OrderStatus.readyForDelivery:
        return const Color(0xFF9C27B0);
      case OrderStatus.completed:
        return const Color(0xFF009688);
      case OrderStatus.dispute:
        return const Color(0xFFF44336);
      case OrderStatus.cancelled:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return Icons.receipt_outlined;
      case OrderStatus.accepted:
        return Icons.check_circle_outline;
      case OrderStatus.inProgress:
        return Icons.build_outlined;
      case OrderStatus.readyForDelivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.dispute:
        return Icons.warning_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_outlined),
                    onPressed: _loadOrders,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOrders,
                color: primary,
                child: _buildBody(context, orderProvider, primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, OrderProvider orderProvider, Color primary) {
    if (orderProvider.isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (orderProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.error_outline, size: 40, color: Colors.red.shade400),
            ),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
            const SizedBox(height: 6),
            Text(orderProvider.error!,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (orderProvider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined, size: 48, color: primary),
            ),
            const SizedBox(height: 20),
            const Text('No orders yet',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 6),
            Text('Your bookings will appear here',
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Browse Mechanics'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final orderWithDetails = orderProvider.orders[index];
        final order = orderWithDetails.order;
        final vehicle = orderWithDetails.vehicle;
        final plan = orderWithDetails.plan;
        final statusColor = _statusColor(order.status);

        return GestureDetector(
          onTap: () => context.push('/orders/${order.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status bar at the top
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.06),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(_statusIcon(order.status), size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _VehicleThumb(vehicle: vehicle),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle?.make ?? 'Vehicle'} ${vehicle?.model ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                if (vehicle?.licensePlate != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300, width: 1.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      vehicle!.licensePlate,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: Color(0xFF424242),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (plan != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${orderWithDetails.payment?.amount.toStringAsFixed(0) ?? plan.totalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                                Text('Total',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 11)),
                              ],
                            ),
                        ],
                      ),

                      if (plan != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.build_outlined,
                                  size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF424242)),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  size: 16, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleThumb extends StatelessWidget {
  final dynamic vehicle;

  const _VehicleThumb({this.vehicle});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final icon = vehicle?.vehicleType == 'bike'
        ? Icons.two_wheeler
        : Icons.directions_car;

    if (vehicle?.images != null && (vehicle!.images as List).isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: vehicle!.images.first as String,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (_, __) => _iconBox(icon, primary),
          errorWidget: (_, __, ___) => _iconBox(icon, primary),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _iconBox(icon, primary),
    );
  }

  Widget _iconBox(IconData icon, Color primary) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 30, color: primary),
    );
  }
}
