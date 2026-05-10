import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../cart/cart_provider.dart';
import '../mechanics/models/mechanic_company.dart';
import '../vehicles/models/vehicle_model.dart';
import '../auth/auth_provider.dart';
import '../addresses/addresses_provider.dart';
import 'order_provider.dart';
import 'order_model.dart';

const _kOrange = Color(0xFFFC8019);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

/// Same order as [SelectVehiclePhotosScreen] checkout payload.
const List<String> kBeforeServicePhotoLabels = [
  'Left side',
  'Right side',
  'Front side',
  'Back side',
];

class CheckoutScreen extends StatefulWidget {
  final MechanicCompany company;
  final VehicleModel vehicle;
  final List<File> beforeImages;

  const CheckoutScreen({
    super.key,
    required this.company,
    required this.vehicle,
    required this.beforeImages,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialInstructionsController = TextEditingController();
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderProvider>().setCheckoutRouteExtra({
        'company': widget.company,
        'vehicle': widget.vehicle,
        'beforeImages': widget.beforeImages,
      });
    });
  }

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectScheduledDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDate),
      );

      if (time != null) {
        setState(() {
          _scheduledDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final addressProvider = context.read<AddressesProvider>();

    if (authProvider.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to place order')),
        );
      }
      return;
    }

    if (addressProvider.selectedAddress == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a service address'),
            action: SnackBarAction(
              label: 'Add Address',
              onPressed: () => context.push('/addresses'),
            ),
          ),
        );
      }
      return;
    }

    if (cartProvider.items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart is empty')),
        );
      }
      return;
    }

    final cartItem = cartProvider.items.first;
    final user = authProvider.user!;
    final serviceAddress = addressProvider.selectedAddress!;

    final request = CreateOrderRequest(
      companyId: widget.company.id,
      userId: user.id,
      planId: cartItem.plan.id,
      vehicleId: widget.vehicle.id,
      scheduledServiceDate: _scheduledDate,
      specialInstructions: _specialInstructionsController.text.isEmpty
          ? null
          : _specialInstructionsController.text,
      contactName: user.name,
      contactPhone: user.phone,
      contactEmail: user.email,
      contactAddress: serviceAddress.fullAddress,
      serviceLatitude: serviceAddress.latitude,
      serviceLongitude: serviceAddress.longitude,
      serviceAddress: serviceAddress.fullAddress,
      amount: cartProvider.total,
      beforeImageUrls: [],
    );

    await orderProvider.createOrderWithPayment(
      request: request,
      beforeImages: widget.beforeImages,
      onPaymentInitiated: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final order = orderProvider.currentOrder!;
          final payment = orderProvider.currentPayment!;
          context.push(
            '/payment-processing',
            extra: {
              'order': order,
              'payment': payment,
              'status': 'processing',
            },
          );
        });
      },
      onPaymentSuccess: (order, payment) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          cartProvider.clear();
          context.go(
            '/order-confirmation',
            extra: {
              'order': order,
              'payment': payment,
            },
          );
        });
      },
      onPaymentError: (order, payment, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.go(
            '/payment-processing',
            extra: {
              'order': order,
              'payment': payment,
              'status': 'failed',
            },
          );
        });
      },
    );

    if (!mounted) return;
    final paymentSetupError = orderProvider.error;
    if (paymentSetupError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentSetupError),
          duration: const Duration(seconds: 8),
        ),
      );
      orderProvider.clearError();
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final addressProvider = context.watch<AddressesProvider>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(color: _kHeading, fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kHeading),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _CheckoutCard(
                      icon: Icons.store_outlined,
                      title: 'Service Provider',
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.company.brandImageUrl != null
                                ? Image.network(
                                    widget.company.brandImageUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _iconPlaceholder(Icons.business),
                                  )
                                : _iconPlaceholder(Icons.business),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.company.companyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: _kHeading,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.company.fullAddress,
                                  style: const TextStyle(color: _kBody, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _CheckoutCard(
                      icon: Icons.location_on_outlined,
                      title: 'Service Location',
                      trailing: addressProvider.selectedAddress != null
                          ? TextButton(
                              onPressed: () async => await context.push('/addresses'),
                              child: const Text('Change',
                                  style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600)),
                            )
                          : null,
                      child: addressProvider.selectedAddress != null
                          ? Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _kOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.home_outlined, color: _kOrange, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        addressProvider.selectedAddress!.label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: _kHeading,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        addressProvider.selectedAddress!.fullAddress,
                                        style: const TextStyle(color: _kBody, fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : _AddAddressPrompt(
                              onTap: () => context.push('/addresses'),
                            ),
                    ),

                    const SizedBox(height: 12),

                    _CheckoutCard(
                      icon: Icons.directions_car_outlined,
                      title: 'Vehicle',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _kOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_car, color: _kOrange, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.vehicle.make} ${widget.vehicle.model}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _kHeading,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.vehicle.year} • ${widget.vehicle.licensePlate}',
                                  style: const TextStyle(color: _kBody, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _CheckoutCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Scheduled Date & Time',
                      trailing: TextButton(
                        onPressed: _selectScheduledDate,
                        child: const Text('Change',
                            style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _kOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.event_available, color: _kOrange, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(_scheduledDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _kHeading,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _CheckoutCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Services',
                      child: Column(
                        children: cartProvider.items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _kBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.plan.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: _kHeading,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.serviceName,
                                        style: const TextStyle(color: _kBody, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${item.subtotal.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: _kOrange,
                                      ),
                                    ),
                                    Text(
                                      '+ ₹${item.taxAmount.toStringAsFixed(0)} tax',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _CheckoutCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Before Service Photos (${widget.beforeImages.length})',
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.beforeImages.length,
                          itemBuilder: (context, index) {
                            final label = index < kBeforeServicePhotoLabels.length
                                ? kBeforeServicePhotoLabels[index]
                                : 'Photo ${index + 1}';
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      widget.beforeImages[index],
                                      width: 82,
                                      height: 82,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 82,
                                    child: Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: _kBody,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _CheckoutCard(
                      icon: Icons.edit_note_outlined,
                      title: 'Special Instructions',
                      child: TextFormField(
                        controller: _specialInstructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Any specific requirements or notes...',
                          hintStyle: const TextStyle(color: _kBody, fontSize: 14),
                          filled: true,
                          fillColor: _kBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Price Details
                    Container(
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: _kOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.calculate_outlined,
                                      color: _kOrange, size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Price Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _kHeading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey.shade100),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _PriceRow(
                                  label: 'Subtotal',
                                  value: '₹${cartProvider.subtotal.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 10),
                                _PriceRow(
                                  label: 'Tax',
                                  value: '₹${cartProvider.taxAmount.toStringAsFixed(2)}',
                                  valueColor: _kBody,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(color: Colors.grey.shade200),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: _kHeading,
                                      ),
                                    ),
                                    Text(
                                      '₹${cartProvider.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                        color: _kOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Payable',
                              style: TextStyle(color: _kBody, fontSize: 13),
                            ),
                            Text(
                              '₹${cartProvider.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: _kOrange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: orderProvider.isLoading ? null : _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kOrange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _kOrange.withOpacity(0.5),
                              minimumSize: const Size(0, 52),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                            ),
                            child: orderProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Pay Now',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconPlaceholder(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: _kBody, size: 26),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _CheckoutCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _kOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _kOrange, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _kHeading,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _AddAddressPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAddressPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kOrange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kOrange.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _kOrange, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No address selected. Tap to add one.',
                style: TextStyle(color: _kOrange.withOpacity(0.9), fontSize: 13),
              ),
            ),
            const Icon(Icons.chevron_right, color: _kOrange),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: _kBody, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? _kHeading,
          ),
        ),
      ],
    );
  }
}
