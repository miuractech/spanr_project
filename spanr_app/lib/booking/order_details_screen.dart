import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'order_provider.dart';
import 'order_types.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<String> _beforeImages = [];
  List<String> _afterImages = [];

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadOrderDetails(widget.orderId);
    _beforeImages = await orderProvider.getBeforeImages(widget.orderId);
    _afterImages = await orderProvider.getAfterImages(widget.orderId);
    setState(() {});
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
    final order = orderProvider.currentOrder;
    final payment = orderProvider.currentPayment;
    final history = orderProvider.currentOrderHistory;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: orderProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: primary))
          : orderProvider.error != null
              ? _buildError(orderProvider.error!)
              : order == null
                  ? const Center(child: Text('Order not found'))
                  : RefreshIndicator(
                      onRefresh: _loadOrderDetails,
                      color: primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Status Hero Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: _statusColor(order.status).withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order.status).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _statusIcon(order.status),
                                      color: _statusColor(order.status),
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.status.displayName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _statusColor(order.status),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                                          style: TextStyle(
                                              color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Timeline
                            if (history.isNotEmpty) ...[
                              _buildDetailCard(
                                context,
                                icon: Icons.timeline,
                                title: 'Order Timeline',
                                child: Column(
                                  children: history.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final item = entry.value;
                                    final isLast = i == history.length - 1;
                                    return IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: _statusColor(item.status)
                                                      .withValues(alpha: 0.15),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: _statusColor(item.status),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Icon(
                                                  _statusIcon(item.status),
                                                  size: 14,
                                                  color: _statusColor(item.status),
                                                ),
                                              ),
                                              if (!isLast)
                                                Expanded(
                                                  child: Container(
                                                    width: 2,
                                                    color: Colors.grey[200],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: isLast ? 0 : 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.status.displayName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                      color: Color(0xFF1A1A1A),
                                                    ),
                                                  ),
                                                  if (item.notes != null)
                                                    Text(item.notes!,
                                                        style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontSize: 13)),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    DateFormat('MMM dd, yyyy • hh:mm a')
                                                        .format(item.createdAt),
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 11),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Service Details
                            _buildDetailCard(
                              context,
                              icon: Icons.build_outlined,
                              title: 'Service Details',
                              child: Column(
                                children: [
                                  _detailRow(
                                    context,
                                    Icons.calendar_today_outlined,
                                    'Scheduled Date',
                                    DateFormat('MMM dd, yyyy • hh:mm a')
                                        .format(order.scheduledServiceDate),
                                  ),
                                  _divider(),
                                  _detailRow(
                                    context,
                                    Icons.location_on_outlined,
                                    'Service Location',
                                    order.serviceAddress,
                                  ),
                                  if (order.specialInstructions != null) ...[
                                    _divider(),
                                    _detailRow(
                                      context,
                                      Icons.note_outlined,
                                      'Special Instructions',
                                      order.specialInstructions!,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Contact Details
                            _buildDetailCard(
                              context,
                              icon: Icons.person_outline,
                              title: 'Contact Details',
                              child: Column(
                                children: [
                                  _detailRow(context, Icons.person_outline,
                                      'Name', order.contactName),
                                  _divider(),
                                  _detailRow(context, Icons.phone_outlined,
                                      'Phone', order.contactPhone),
                                  _divider(),
                                  _detailRow(context, Icons.email_outlined,
                                      'Email', order.contactEmail),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Payment Details
                            if (payment != null) ...[
                              _buildDetailCard(
                                context,
                                icon: Icons.payments_outlined,
                                title: 'Payment Details',
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Amount',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13)),
                                        Text(
                                          '₹${payment.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Status',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: payment.status ==
                                                    PaymentStatus.paid
                                                ? Colors.green.withValues(alpha: 0.1)
                                                : Colors.orange.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                payment.status == PaymentStatus.paid
                                                    ? Icons.check_circle
                                                    : Icons.pending,
                                                size: 14,
                                                color: payment.status ==
                                                        PaymentStatus.paid
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                payment.status == PaymentStatus.paid
                                                    ? 'Paid'
                                                    : 'Unpaid',
                                                style: TextStyle(
                                                  color: payment.status ==
                                                          PaymentStatus.paid
                                                      ? Colors.green
                                                      : Colors.orange,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (payment.paidAt != null) ...[
                                      _divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Paid At',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13)),
                                          Text(
                                            DateFormat('MMM dd, yyyy • hh:mm a')
                                                .format(payment.paidAt!),
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Before Photos
                            if (_beforeImages.isNotEmpty) ...[
                              _buildDetailCard(
                                context,
                                icon: Icons.photo_library_outlined,
                                title: 'Before Service Photos',
                                child: _imageStrip(_beforeImages),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // After Photos
                            if (_afterImages.isNotEmpty) ...[
                              _buildDetailCard(
                                context,
                                icon: Icons.photo_library_outlined,
                                title: 'After Service Photos',
                                child: _imageStrip(_afterImages),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Cancel Button
                            if (order.status == OrderStatus.created ||
                                order.status == OrderStatus.accepted) ...[
                              OutlinedButton.icon(
                                onPressed: () => _confirmCancel(context, orderProvider),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel Order'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext context, OrderProvider orderProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await orderProvider.cancelOrder(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
        await _loadOrderDetails();
      }
    }
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Error: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _loadOrderDetails, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _detailRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1, color: Colors.grey.shade100),
      );

  Widget _imageStrip(List<String> images) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: images[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: Colors.grey[200], width: 100, height: 100),
              errorWidget: (_, __, ___) =>
                  Container(color: Colors.grey[200], width: 100, height: 100,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey)),
            ),
          ),
        ),
      ),
    );
  }
}
