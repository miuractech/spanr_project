import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/supabase_config.dart';
import 'order_model.dart';
import 'order_types.dart';

class OrderService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  late Razorpay _razorpay;

  // Callbacks for Razorpay
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  OrderService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }

  // Upload before service images
  Future<List<String>> uploadBeforeImages(
    String orderId,
    List<File> images,
  ) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final fileExt = file.path.split('.').last;
      final fileName = '${orderId}_before_${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt';
      final filePath = 'order_images/before/$fileName';

      try {
        // Upload to Supabase Storage
        await _supabase.storage.from('orders').upload(
              filePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Get public URL
        final publicUrl = _supabase.storage.from('orders').getPublicUrl(filePath);
        uploadedUrls.add(publicUrl);
      } catch (e) {
        if (_isRlsViolationError(e)) {
          throw Exception('Unable to upload vehicle photos. Please check app permissions and try again.');
        }
        rethrow;
      }
    }

    return uploadedUrls;
  }

  // Save before image URLs to database
  Future<void> saveBeforeImageRecords(
    String orderId,
    List<String> imageUrls,
  ) async {
    if (imageUrls.isEmpty) return;

    final records = imageUrls
        .map((url) => {
              'order_id': orderId,
              'image_url': url,
            })
        .toList();

    try {
      await _supabase.from('order_before_images').insert(records);
    } catch (e) {
      if (_isRlsViolationError(e)) {
        // Payment/order creation should still continue.
        return;
      }
      rethrow;
    }
  }

  bool _isRlsViolationError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('row-level security') ||
        message.contains('violates row-level security policy') ||
        message.contains('unauthorized');
  }

  // Create order in database
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    final response = await _supabase
        .from('orders')
        .insert(request.toJson())
        .select()
        .single();

    return OrderModel.fromJson(response);
  }

  // Create payment record
  Future<PaymentModel> createPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
    String? razorpayOrderId,
  }) async {
    final response = await _supabase
        .from('payments')
        .insert({
          'order_id': orderId,
          'amount': amount,
          'method': method.dbValue,
          'status': PaymentStatus.unpaid.dbValue,
          'razorpay_order_id': razorpayOrderId,
        })
        .select()
        .single();

    return PaymentModel.fromJson(response);
  }

  // Update payment to processing status
  Future<PaymentModel> updatePaymentProcessing({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _supabase
        .from('payments')
        .update({
          'status': PaymentStatus.processing.dbValue,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        })
        .eq('id', paymentId)
        .eq('status', PaymentStatus.unpaid.dbValue)
        .select()
        .maybeSingle();

    if (response != null) {
      return PaymentModel.fromJson(response);
    }
    return getPaymentById(paymentId);
  }

  // Poll payment status until it's resolved (paid or failed)
  Future<PaymentModel> waitForPaymentResolution({
    required String paymentId,
    int maxAttempts = 45,
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      final payment = await getPaymentById(paymentId);

      if (payment.status == PaymentStatus.paid ||
          payment.status == PaymentStatus.failed) {
        return payment;
      }

      if (i < maxAttempts - 1) {
        await Future.delayed(pollInterval);
      }
    }

    // If timeout, fetch latest status
    return await getPaymentById(paymentId);
  }

  // Get payment by ID
  Future<PaymentModel> getPaymentById(String paymentId) async {
    final response = await _supabase
        .from('payments')
        .select()
        .eq('id', paymentId)
        .single();

    return PaymentModel.fromJson(response);
  }

  // Request payment-related permissions
  Future<void> _requestPaymentPermissions() async {
    if (!Platform.isAndroid) return;
    // Optional for Razorpay; do not await settings — blocks checkout indefinitely.
    await Permission.phone.request();
  }

  // Open Razorpay payment gateway
  Future<void> openRazorpay({
    required String razorpayOrderId,
    required double amount,
    required String name,
    required String email,
    required String phone,
    required String description,
  }) async {
    await _requestPaymentPermissions();

    final keyId = SupabaseConfig.razorpayKeyId.trim();
    if (keyId.isEmpty) {
      throw Exception(
        'RAZORPAY_KEY_ID is missing. Add it to spanr_app/.env and rebuild.',
      );
    }

    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // amount in paise
      'currency': 'INR',
      'name': 'SPANR',
      'description': description,
      'order_id': razorpayOrderId,
      'prefill': {
        'contact': phone,
        'email': email,
        'name': name,
      },
      'theme': {
        'color': '#FC8019',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      throw Exception('Failed to open Razorpay: $e');
    }
  }

  // Get user orders with details
  Future<List<OrderWithDetails>> getUserOrders(String userId) async {
    final response = await _supabase
        .from('orders')
        .select('''
          *,
          vehicles (*),
          plans (*, services:service_id (*)),
          payments (*)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      // Flatten services structure from plans
      if (json['plans'] != null && json['plans']['services'] != null) {
        json['services'] = json['plans']['services'];
      }
      return OrderWithDetails.fromJson(json);
    }).toList();
  }

  // Get order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _supabase
        .from('orders')
        .select()
        .eq('id', orderId)
        .single();

    return OrderModel.fromJson(response);
  }

  // Get order history
  Future<List<OrderHistoryModel>> getOrderHistory(String orderId) async {
    final response = await _supabase
        .from('order_history')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => OrderHistoryModel.fromJson(json))
        .toList();
  }

  // Get payment for order
  Future<PaymentModel?> getOrderPayment(String orderId) async {
    final response = await _supabase
        .from('payments')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();

    if (response == null) return null;
    return PaymentModel.fromJson(response);
  }

  // Get before images for order
  Future<List<String>> getBeforeImages(String orderId) async {
    final response = await _supabase
        .from('order_before_images')
        .select('image_url')
        .eq('order_id', orderId);

    return (response as List)
        .map((json) => json['image_url'] as String)
        .toList();
  }

  // Get after images for order
  Future<List<String>> getAfterImages(String orderId) async {
    final response = await _supabase
        .from('order_after_images')
        .select('image_url')
        .eq('order_id', orderId);

    return (response as List)
        .map((json) => json['image_url'] as String)
        .toList();
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _supabase
        .from('orders')
        .update({'status': OrderStatus.cancelled.dbValue})
        .eq('id', orderId);
  }

  // Create Razorpay order via Supabase Edge Function
  // Note: You'll need to create this Edge Function
  Future<String> createRazorpayOrder({
    required double amount,
    required String orderId,
  }) async {
    // Call Supabase Edge Function to create Razorpay order
    final response = await _supabase.functions.invoke(
      'create-razorpay-order',
      body: {
        'amount': (amount * 100).toInt(), // amount in paise
        'currency': 'INR',
        'receipt': orderId,
      },
    );

    final status = response.status;
    final data = response.data;

    if (status != 200) {
      String msg = 'HTTP $status';
      if (data is Map && data['error'] != null) {
        msg = '${data['error']}';
      } else if (data != null) {
        msg = data.toString();
      }
      throw Exception(
        'Could not start payment ($msg). Deploy create-razorpay-order and set RAZORPAY secrets on Supabase.',
      );
    }

    if (data is! Map || data['id'] == null) {
      throw Exception('Invalid Razorpay response from server');
    }

    return data['id'] as String;
  }

  // Complete order flow: create order, upload images, create payment, initiate Razorpay
  Future<Map<String, dynamic>> initiateOrder({
    required CreateOrderRequest request,
    required List<File> beforeImages,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) async {
    // Set callbacks
    onPaymentSuccess = onSuccess;
    onPaymentError = onError;

    // 1. Create order
    final order = await createOrder(request);

    // 2. Upload before images
    final imageUrls = await uploadBeforeImages(order.id, beforeImages);

    // 3. Save image records
    await saveBeforeImageRecords(order.id, imageUrls);

    // 4. Create Razorpay order
    final razorpayOrderId = await createRazorpayOrder(
      amount: request.amount,
      orderId: order.id,
    );

    // 5. Create payment record
    final payment = await createPayment(
      orderId: order.id,
      amount: request.amount,
      method: PaymentMethod.upi, // Default, can be changed
      razorpayOrderId: razorpayOrderId,
    );

    // Return order and payment details
    return {
      'order': order,
      'payment': payment,
      'razorpay_order_id': razorpayOrderId,
    };
  }

  // Get order with details (including payment, plan, company)
  Future<Map<String, dynamic>> getOrderWithDetails(String orderId) async {
    final order = await getOrderById(orderId);
    final payment = await getOrderPayment(orderId);
    final beforeImages = await getBeforeImages(orderId);
    final afterImages = await getAfterImages(orderId);

    return {
      'order': order,
      'payment': payment,
      'before_images': beforeImages,
      'after_images': afterImages,
    };
  }

  // Get extra work requests for an order
  Future<List<ExtraWorkRequest>> getExtraWorkRequests(String orderId) async {
    final response = await _supabase
        .from('extra_work_requests')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
    return (response as List).map((j) => ExtraWorkRequest.fromJson(j)).toList();
  }

  // Approve an extra work request
  Future<void> approveExtraWork(String requestId) async {
    await _supabase
        .from('extra_work_requests')
        .update({
          'status': 'approved',
          'customer_response_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('status', 'pending');
  }

  // Reject an extra work request
  Future<void> rejectExtraWork(String requestId, {String? reason}) async {
    await _supabase
        .from('extra_work_requests')
        .update({
          'status': 'rejected',
          'rejection_reason': reason,
          'customer_response_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('status', 'pending');
  }
}
