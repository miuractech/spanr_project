import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/auth_provider.dart';
import 'order_provider.dart';
import 'order_types.dart';

const _kOrange = Color(0xFFFC8019);
const _kBg = Color(0xFFF2F2F2);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);

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
      case OrderStatus.onHold:
        return const Color(0xFFFFC107);
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
      case OrderStatus.onHold:
        return Icons.pause_circle_outline;
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

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _kHeading,
                      ),
                    ),
                  ),
                  Material(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _loadOrders,
                      child: const Padding(
                        padding: EdgeInsets.all(9),
                        child: Icon(Icons.refresh_rounded, size: 22, color: _kHeading),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOrders,
                color: _kOrange,
                child: _buildBody(context, orderProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kOrange, strokeWidth: 3),
      );
    }

    if (orderProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, size: 40, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kHeading),
              ),
              const SizedBox(height: 6),
              Text(
                orderProvider.error!,
                style: const TextStyle(color: _kBody, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (orderProvider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _kOrange.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 48, color: _kOrange),
            ),
            const SizedBox(height: 20),
            const Text(
              'No orders yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _kHeading),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your bookings will appear here',
              style: TextStyle(color: _kBody, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Browse Mechanics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status color bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),

                // Status row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(order.status), size: 14, color: statusColor),
                            const SizedBox(width: 5),
                            Text(
                              order.status.displayName,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _kHeading,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (vehicle?.licensePlate != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFBBBBBB), width: 1.5),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      vehicle!.licensePlate,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: _kHeading,
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _kOrange,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                ),
                              ],
                            ),
                        ],
                      ),

                      if (plan != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: _kBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.build_outlined, size: 14, color: _kBody),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kHeading,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
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
    final icon = vehicle?.vehicleType == 'bike'
        ? Icons.two_wheeler
        : Icons.directions_car;

    if (vehicle?.images != null && (vehicle!.images as List).isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: vehicle!.images.first as String,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (_, __) => _iconBox(icon),
          errorWidget: (_, __, ___) => _iconBox(icon),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _iconBox(icon),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _kOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 28, color: _kOrange),
    );
  }
}
