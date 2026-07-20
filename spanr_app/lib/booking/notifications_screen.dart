import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../config/supabase_config.dart';
import 'order_types.dart';

const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

/// A lightweight notification item built from order_history + extra_work_requests.
class _NotifItem {
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final Color color;
  final String? orderId;

  const _NotifItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.orderId,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_NotifItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId == null) throw Exception('Not logged in');

      final supabase = SupabaseConfig.client;

      // Get user's order IDs
      final ordersRes = await supabase
          .from('orders')
          .select('id')
          .eq('user_id', userId);
      final orderIds = (ordersRes as List).map((o) => o['id'] as String).toList();

      if (orderIds.isEmpty) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch order history (status changes) and extra work requests in parallel
      final results = await Future.wait([
        supabase
            .from('order_history')
            .select()
            .inFilter('order_id', orderIds)
            .order('created_at', ascending: false)
            .limit(50),
        supabase
            .from('extra_work_requests')
            .select()
            .inFilter('order_id', orderIds)
            .order('created_at', ascending: false)
            .limit(50),
      ]);

      final historyRows = results[0] as List;
      final extraWorkRows = results[1] as List;

      final items = <_NotifItem>[];

      // Convert status changes to notifications
      // Only show meaningful ones: accepted, in_progress, on_hold, ready_for_delivery, completed, cancelled
      const skipStatuses = {'created'}; // user created it, not a notification
      for (final row in historyRows) {
        final statusStr = row['status'] as String;
        if (skipStatuses.contains(statusStr)) continue;

        final status = OrderStatus.fromDbValue(statusStr);
        final orderId = row['order_id'] as String;
        final shortId = orderId.substring(0, 8).toUpperCase();
        final time = DateTime.parse(row['created_at'] as String);
        final notes = row['notes'] as String?;

        String title;
        String body;
        IconData icon;
        Color color;

        switch (status) {
          case OrderStatus.accepted:
            title = 'Order Accepted';
            body = 'Your order #$shortId has been accepted by the mechanic.';
            icon = Icons.check_circle_outline;
            color = const Color(0xFF4CAF50);
          case OrderStatus.inProgress:
            title = 'Work Started';
            body = 'The mechanic has started working on order #$shortId.';
            icon = Icons.build_outlined;
            color = _kOrange;
          case OrderStatus.onHold:
            title = 'Order On Hold';
            body = 'Order #$shortId is on hold — the mechanic needs your approval for extra work.';
            icon = Icons.pause_circle_outline;
            color = const Color(0xFFFF9800);
          case OrderStatus.readyForDelivery:
            title = 'Ready for Pickup';
            body = 'Your vehicle for order #$shortId is ready for delivery.';
            icon = Icons.local_shipping_outlined;
            color = const Color(0xFF9C27B0);
          case OrderStatus.completed:
            title = 'Service Completed';
            body = 'Order #$shortId has been completed.';
            icon = Icons.done_all;
            color = const Color(0xFF009688);
          case OrderStatus.cancelled:
            title = 'Order Cancelled';
            body = 'Order #$shortId has been cancelled.';
            icon = Icons.cancel_outlined;
            color = const Color(0xFF9E9E9E);
          case OrderStatus.dispute:
            title = 'Dispute Raised';
            body = 'A dispute has been raised on order #$shortId.';
            icon = Icons.warning_outlined;
            color = const Color(0xFFF44336);
          default:
            continue;
        }

        if (notes != null && notes.isNotEmpty) {
          body += '\n$notes';
        }

        items.add(_NotifItem(
          title: title,
          body: body,
          time: time,
          icon: icon,
          color: color,
          orderId: orderId,
        ));
      }

      // Convert extra work requests to notifications
      for (final row in extraWorkRows) {
        final orderId = row['order_id'] as String;
        final time = DateTime.parse(row['created_at'] as String);
        final description = row['description'] as String;
        final cost = (row['estimated_cost'] as num).toDouble();
        final status = row['status'] as String;

        if (status != 'pending') continue; // only show pending ones as actionable

        items.add(_NotifItem(
          title: 'Extra Work Requested',
          body: '$description\nEstimated cost: ₹${cost.toStringAsFixed(0)} — Tap to review.',
          time: time,
          icon: Icons.handyman_outlined,
          color: const Color(0xFFFF9800),
          orderId: orderId,
        ));
      }

      // Sort by time descending
      items.sort((a, b) => b.time.compareTo(a.time));

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kHeading),
        title: const Text('Notifications',
            style: TextStyle(color: _kHeading, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kOrange))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: _kBody)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey[300]),
                          const SizedBox(height: 14),
                          Text('No notifications yet',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                          const SizedBox(height: 6),
                          Text('Order updates will appear here',
                              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _kOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _items.length,
                        itemBuilder: (context, i) => _buildNotifCard(_items[i]),
                      ),
                    ),
    );
  }

  Widget _buildNotifCard(_NotifItem item) {
    final timeStr = _formatTime(item.time);

    return GestureDetector(
      onTap: item.orderId != null ? () => context.push('/orders/${item.orderId}') : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: _kHeading)),
                      ),
                      Text(timeStr,
                          style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.body,
                      style: const TextStyle(fontSize: 13, color: _kBody, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(time);
  }
}
