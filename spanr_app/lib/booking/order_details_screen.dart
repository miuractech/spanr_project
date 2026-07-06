import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'order_provider.dart';
import 'order_types.dart';

const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

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
      case OrderStatus.onHold:
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
    final order = orderProvider.currentOrder;
    final payment = orderProvider.currentPayment;
    final history = orderProvider.currentOrderHistory;
    final extraWorkRequests = orderProvider.extraWorkRequests;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text('Order Details',
            style: TextStyle(color: _kHeading, fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kHeading),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: _kOrange))
          : orderProvider.error != null
              ? _buildError(orderProvider.error!)
              : order == null
                  ? const Center(
                      child: Text('Order not found', style: TextStyle(color: _kBody)))
                  : RefreshIndicator(
                      onRefresh: _loadOrderDetails,
                      color: _kOrange,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Status Hero Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: _statusColor(order.status).withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order.status).withOpacity(0.15),
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
                                            fontWeight: FontWeight.w800,
                                            color: _statusColor(order.status),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                                          style: const TextStyle(color: _kBody, fontSize: 13),
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
                                                      .withOpacity(0.15),
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
                                                      color: _kHeading,
                                                    ),
                                                  ),
                                                  if (item.notes != null)
                                                    Text(item.notes!,
                                                        style: const TextStyle(
                                                            color: _kBody,
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

                            // Extra Work Requests
                            if (extraWorkRequests.isNotEmpty ||
                                order.status == OrderStatus.onHold) ...[
                              _buildDetailCard(
                                icon: Icons.warning_amber_outlined,
                                title: 'Extra Work Requests',
                                child: extraWorkRequests.isEmpty
                                    ? const Text(
                                        'Your order is on hold pending mechanic review.',
                                        style: TextStyle(color: _kBody, fontSize: 13),
                                      )
                                    : Column(
                                        children: extraWorkRequests
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final i = entry.key;
                                          final request = entry.value;
                                          final isLast =
                                              i == extraWorkRequests.length - 1;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Description
                                              Text(
                                                request.description,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: _kHeading,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              // Estimated cost
                                              Text(
                                                'Estimated cost: ₹${request.estimatedCost.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: _kOrange,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              // Photo thumbnail
                                              if (request.photoUrl != null) ...[
                                                const SizedBox(height: 10),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl: request.photoUrl!,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    placeholder: (_, __) =>
                                                        Container(
                                                      color: _kBg,
                                                      width: 100,
                                                      height: 100,
                                                    ),
                                                    errorWidget: (_, __, ___) =>
                                                        Container(
                                                      color: _kBg,
                                                      width: 100,
                                                      height: 100,
                                                      child: const Icon(
                                                          Icons.image_not_supported,
                                                          color: _kBody),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 10),
                                              // Status badge
                                              _buildStatusBadge(request.status),
                                              // Rejection reason
                                              if (request.isRejected &&
                                                  request.rejectionReason != null) ...[
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Reason: ${request.rejectionReason}',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                              // Action buttons for pending requests
                                              if (request.isPending) ...[
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            _confirmApproveExtraWork(
                                                          context,
                                                          orderProvider,
                                                          request,
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: _kOrange,
                                                          foregroundColor: Colors.white,
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(24),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                  vertical: 12),
                                                        ),
                                                        child: const Text(
                                                          'Approve',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.w700),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        onPressed: () =>
                                                            _promptRejectExtraWork(
                                                          context,
                                                          orderProvider,
                                                          request,
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: Colors.red,
                                                          side: const BorderSide(
                                                              color: Colors.red,
                                                              width: 1.5),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(24),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                  vertical: 12),
                                                        ),
                                                        child: const Text(
                                                          'Reject',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.w700),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              if (!isLast) ...[
                                                const SizedBox(height: 16),
                                                Divider(
                                                    height: 1,
                                                    color: Colors.grey.shade100),
                                                const SizedBox(height: 16),
                                              ],
                                            ],
                                          );
                                        }).toList(),
                                      ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Service Details
                            _buildDetailCard(
                              icon: Icons.build_outlined,
                              title: 'Service Details',
                              child: Column(
                                children: [
                                  _detailRow(
                                    Icons.calendar_today_outlined,
                                    'Scheduled Date',
                                    DateFormat('MMM dd, yyyy • hh:mm a')
                                        .format(order.scheduledServiceDate),
                                  ),
                                  _divider(),
                                  _detailRow(
                                    Icons.location_on_outlined,
                                    'Service Location',
                                    order.serviceAddress,
                                  ),
                                  if (order.specialInstructions != null) ...[
                                    _divider(),
                                    _detailRow(
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
                              icon: Icons.person_outline,
                              title: 'Contact Details',
                              child: Column(
                                children: [
                                  _detailRow(Icons.person_outline,
                                      'Name', order.contactName),
                                  _divider(),
                                  _detailRow(Icons.phone_outlined,
                                      'Phone', order.contactPhone),
                                  _divider(),
                                  _detailRow(Icons.email_outlined,
                                      'Email', order.contactEmail),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Payment Details
                            if (payment != null) ...[
                              _buildDetailCard(
                                icon: Icons.payments_outlined,
                                title: 'Payment Details',
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Amount',
                                            style: TextStyle(
                                                color: _kBody, fontSize: 13)),
                                        Text(
                                          '₹${payment.amount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: _kOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Status',
                                            style: TextStyle(
                                                color: _kBody, fontSize: 13)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: payment.status ==
                                                    PaymentStatus.paid
                                                ? const Color(0xFF267E3E).withOpacity(0.1)
                                                : _kOrange.withOpacity(0.1),
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
                                                    ? const Color(0xFF267E3E)
                                                    : _kOrange,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                payment.status == PaymentStatus.paid
                                                    ? 'Paid'
                                                    : 'Unpaid',
                                                style: TextStyle(
                                                  color: payment.status ==
                                                          PaymentStatus.paid
                                                      ? const Color(0xFF267E3E)
                                                      : _kOrange,
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
                                          const Text('Paid At',
                                              style: TextStyle(
                                                  color: _kBody, fontSize: 13)),
                                          Text(
                                            DateFormat('MMM dd, yyyy • hh:mm a')
                                                .format(payment.paidAt!),
                                            style: const TextStyle(
                                                color: _kHeading,
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
                                icon: Icons.photo_library_outlined,
                                title: 'Before Service Photos',
                                child: _imageStrip(_beforeImages),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // After Photos
                            if (_afterImages.isNotEmpty) ...[
                              _buildDetailCard(
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
                                  side: const BorderSide(color: Colors.red, width: 1.5),
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28)),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = _kOrange;
        label = 'Pending Approval';
        icon = Icons.hourglass_empty_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmApproveExtraWork(
    BuildContext context,
    OrderProvider orderProvider,
    ExtraWorkRequest request,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Extra Work', style: TextStyle(color: _kHeading)),
        content: Text(
          'Approve additional work for ₹${request.estimatedCost.toStringAsFixed(2)}?\n\n"${request.description}"',
          style: const TextStyle(color: _kBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: _kBody),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await orderProvider.approveExtraWork(request.id, widget.orderId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Extra work approved.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _promptRejectExtraWork(
    BuildContext context,
    OrderProvider orderProvider,
    ExtraWorkRequest request,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Extra Work', style: TextStyle(color: _kHeading)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${request.description}"',
              style: const TextStyle(color: _kBody, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for rejection (optional)',
                hintStyle: const TextStyle(color: _kBody, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kOrange),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: _kBody),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final reason =
          reasonController.text.trim().isEmpty ? null : reasonController.text.trim();
      try {
        await orderProvider.rejectExtraWork(request.id, widget.orderId, reason: reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Extra work rejected.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    reasonController.dispose();
  }

  Future<void> _confirmCancel(
      BuildContext context, OrderProvider orderProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Order', style: TextStyle(color: _kHeading)),
        content: const Text('Are you sure you want to cancel this order?',
            style: TextStyle(color: _kBody)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: _kBody),
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
          Text('Error: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kBody)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrderDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _kOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _kOrange, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kHeading,
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _kOrange),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: _kBody, fontSize: 11)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: _kHeading)),
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
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: images[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: _kBg, width: 100, height: 100),
              errorWidget: (_, __, ___) =>
                  Container(color: _kBg, width: 100, height: 100,
                    child: const Icon(Icons.image_not_supported, color: _kBody)),
            ),
          ),
        ),
      ),
    );
  }
}
