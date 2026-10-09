import 'dart:io';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'order_service.dart';
import 'order_model.dart';
import 'order_types.dart';

String userFacingPaymentError(
  Object? raw, {
  String fallback = 'Payment cancelled. Extra charges are still unpaid.',
}) {
  final text = (raw ?? '').toString().trim();
  final lower = text.toLowerCase();
  if (text.isEmpty ||
      lower == 'null' ||
      lower == 'undefined' ||
      lower == 'none' ||
      lower == 'payment failed: null' ||
      lower == 'payment failed: undefined' ||
      lower.endsWith(': undefined') ||
      lower.endsWith(': null')) {
    return fallback;
  }
  return text;
}

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderWithDetails> _orders = [];
  List<OrderHistoryModel> _currentOrderHistory = [];
  List<ExtraWorkRequest> _extraWorkRequests = [];
  List<PartReplacement> _partsReplaced = [];
  PaymentModel? _pendingAdditional;
  bool _isLoading = false;
  String? _error;
  OrderModel? _currentOrder;
  PaymentModel? _currentPayment;
  Map<String, dynamic>? _checkoutRouteExtra;
  bool _checkoutBusy = false;
  String? _handledRazorpayPaymentId;

  List<OrderWithDetails> get orders => _orders;
  List<OrderHistoryModel> get currentOrderHistory => _currentOrderHistory;
  List<ExtraWorkRequest> get extraWorkRequests => _extraWorkRequests;
  List<PartReplacement> get partsReplaced => _partsReplaced;
  PaymentModel? get pendingAdditional => _pendingAdditional;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderModel? get currentOrder => _currentOrder;
  PaymentModel? get currentPayment => _currentPayment;
  Map<String, dynamic>? get checkoutRouteExtra => _checkoutRouteExtra;

  void setCheckoutRouteExtra(Map<String, dynamic> extra) {
    _checkoutRouteExtra = extra;
  }

  @override
  void dispose() {
    _orderService.dispose();
    super.dispose();
  }

  // Load user orders
  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getUserOrders(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load order details
  Future<void> loadOrderDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await _orderService.getOrderById(orderId);
      _currentPayment = await _orderService.getOrderPayment(orderId);
      _pendingAdditional =
          await _orderService.getPendingAdditionalPayment(orderId);
      _currentOrderHistory = await _orderService.getOrderHistory(orderId);
      _extraWorkRequests = await _orderService.getExtraWorkRequests(orderId);
      _partsReplaced = await _orderService.getPartsReplaced(orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load order history
  Future<void> loadOrderHistory(String orderId) async {
    try {
      _currentOrderHistory = await _orderService.getOrderHistory(orderId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Approve an extra work request and reload order details
  Future<void> approveExtraWork(String requestId, String orderId) async {
    // The database resumes the order once no request is pending (migration 057).
    await _orderService.approveExtraWork(requestId);
    await loadOrderDetails(orderId);
  }

  // Reject an extra work request and reload order details
  Future<void> rejectExtraWork(
    String requestId,
    String orderId, {
    String? reason,
  }) async {
    await _orderService.rejectExtraWork(requestId, reason: reason);
    await loadOrderDetails(orderId);
  }

  Future<PaymentModel> _confirmRazorpayCheckout({
    required String paymentId,
    required PaymentSuccessResponse response,
    bool allowWebhookWait = true,
  }) async {
    var current = await _orderService.getPaymentById(paymentId);
    if (current.status == PaymentStatus.paid ||
        current.status == PaymentStatus.failed) {
      return current;
    }

    final razorpayOrderId =
        (response.orderId?.isNotEmpty == true)
            ? response.orderId!
            : (current.razorpayOrderId ?? '');
    final razorpayPaymentId = response.paymentId ?? '';
    final razorpaySignature = response.signature ?? '';

    if (razorpayPaymentId.isEmpty || razorpaySignature.isEmpty) {
      return current;
    }

    if (razorpayOrderId.isNotEmpty) {
      try {
        return await _orderService.verifyRazorpayPayment(
          paymentId: paymentId,
          razorpayOrderId: razorpayOrderId,
          razorpayPaymentId: razorpayPaymentId,
          razorpaySignature: razorpaySignature,
        );
      } catch (_) {}
    }

    if (!allowWebhookWait) {
      return current;
    }

    if (current.status == PaymentStatus.unpaid) {
      try {
        current = await _orderService.updatePaymentProcessing(
          paymentId: paymentId,
          razorpayPaymentId: razorpayPaymentId,
          razorpaySignature: razorpaySignature,
        );
      } catch (_) {
        current = await _orderService.getPaymentById(paymentId);
      }
    }

    if (current.status == PaymentStatus.paid ||
        current.status == PaymentStatus.failed) {
      return current;
    }

    return _orderService.waitForPaymentResolution(paymentId: paymentId);
  }

  // Create order with payment
  Future<void> createOrderWithPayment({
    required CreateOrderRequest request,
    required List<File> beforeImages,
    required Function() onPaymentInitiated,
    required Function(OrderModel order, PaymentModel payment) onPaymentSuccess,
    required Function(OrderModel order, PaymentModel payment, String error) onPaymentError,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.initiateOrder(
        request: request,
        beforeImages: beforeImages,
        onSuccess: (PaymentSuccessResponse response) async {
          try {
            _isLoading = false;
            notifyListeners();

            // Notify that payment is initiated and start waiting
            onPaymentInitiated();

            final finalPayment = await _confirmRazorpayCheckout(
              paymentId: _currentPayment!.id,
              response: response,
            );

            _currentPayment = finalPayment;

            // Check final payment status
            if (finalPayment.status == PaymentStatus.paid) {
              onPaymentSuccess(_currentOrder!, finalPayment);
            } else if (finalPayment.status == PaymentStatus.failed) {
              onPaymentError(
                _currentOrder!,
                finalPayment,
                finalPayment.failureReason ?? 'Payment verification failed',
              );
            } else {
              // Timeout or still processing
              onPaymentError(
                _currentOrder!,
                finalPayment,
                'Payment verification timeout. Please check your order status.',
              );
            }
          } catch (e) {
            _error = 'Payment verification failed: $e';
            _isLoading = false;
            notifyListeners();
            onPaymentError(
              _currentOrder!,
              _currentPayment!,
              _error!,
            );
          }
        },
        onError: (PaymentFailureResponse response) {
          final cancelled = response.code == Razorpay.PAYMENT_CANCELLED;
          _error = userFacingPaymentError(
            response.message,
            fallback: cancelled
                ? 'Payment cancelled. Your order is still unpaid.'
                : 'Payment failed. Please try again.',
          );
          _isLoading = false;
          notifyListeners();
          onPaymentError(
            _currentOrder!,
            _currentPayment!,
            _error!,
          );
        },
      );

      _currentOrder = result['order'] as OrderModel;
      _currentPayment = result['payment'] as PaymentModel;
      final razorpayOrderId = result['razorpay_order_id'] as String;
      final amountPaise = result['amount_paise'] as int;

      _isLoading = false;
      notifyListeners();

      try {
        await _orderService.openRazorpay(
          razorpayOrderId: razorpayOrderId,
          amountPaise: amountPaise,
          name: request.contactName,
          email: request.contactEmail,
          phone: request.contactPhone,
          description: 'Order payment for ${_currentOrder!.id}',
        );
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        if (_currentOrder != null && _currentPayment != null) {
          onPaymentError(_currentOrder!, _currentPayment!, _error!);
        }
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      if (_currentOrder != null && _currentPayment != null) {
        onPaymentError(_currentOrder!, _currentPayment!, _error!);
      }
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _orderService.cancelOrder(orderId);
      if (_currentOrder != null) {
        await loadUserOrders(_currentOrder!.userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get before images
  Future<List<String>> getBeforeImages(String orderId) async {
    return await _orderService.getBeforeImages(orderId);
  }

  // Get after images
  Future<List<String>> getAfterImages(String orderId) async {
    return await _orderService.getAfterImages(orderId);
  }

  Future<void> payPendingAdditional({
    required Function() onPaymentInitiated,
    required Function(OrderModel order, PaymentModel payment) onPaymentSuccess,
    required Function(OrderModel order, PaymentModel payment, String error)
        onPaymentError,
  }) async {
    final order = _currentOrder;
    var extra = _pendingAdditional;
    if (order == null || extra == null) return;

    final extraPay = extra;
    if (_checkoutBusy) return;
    _checkoutBusy = true;
    try {
      _orderService.onPaymentSuccess = (response) async {
        final rzpPayId = response.paymentId ?? '';
        if (rzpPayId.isNotEmpty && _handledRazorpayPaymentId == rzpPayId) {
          return;
        }
        _handledRazorpayPaymentId = rzpPayId;
        onPaymentInitiated();
        try {
          final resolved = await _confirmRazorpayCheckout(
            paymentId: extraPay.id,
            response: response,
            allowWebhookWait: false,
          );
          if (resolved.status == PaymentStatus.paid) {
            onPaymentSuccess(order, resolved);
          } else {
            onPaymentError(
              order,
              resolved,
              'Payment was not completed. Please try again.',
            );
          }
        } finally {
          _checkoutBusy = false;
          await loadOrderDetails(order.id);
        }
      };
      _orderService.onPaymentError = (response) {
        _checkoutBusy = false;
        onPaymentError(
          order,
          extraPay,
          userFacingPaymentError(
            response.message,
            fallback: 'Payment cancelled. Extra charges are still unpaid.',
          ),
        );
      };
      _orderService.onExternalWallet = (_) {
        _checkoutBusy = false;
        onPaymentError(
          order,
          extraPay,
          'Payment cancelled. Extra charges are still unpaid.',
        );
      };

      final razorpayOrder = await _orderService.createRazorpayOrder(
        paymentId: extra.id,
        amountRupees: extra.amount,
        receipt: extra.id,
      );
      extra = await _orderService.getPaymentById(extra.id);
      _pendingAdditional = extra;

      await _orderService.openRazorpay(
        razorpayOrderId: razorpayOrder.id,
        amountPaise: razorpayOrder.amountPaise,
        name: order.contactName,
        email: order.contactEmail,
        phone: order.contactPhone,
        description: 'Additional parts and repairs for order',
      );
    } catch (e) {
      _checkoutBusy = false;
      onPaymentError(
        order,
        extraPay,
        userFacingPaymentError(
          e,
          fallback: 'Could not start payment. Please try again.',
        ),
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
