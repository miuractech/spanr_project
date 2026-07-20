import 'dart:io';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'order_service.dart';
import 'order_model.dart';
import 'order_types.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderWithDetails> _orders = [];
  List<OrderHistoryModel> _currentOrderHistory = [];
  List<ExtraWorkRequest> _extraWorkRequests = [];
  bool _isLoading = false;
  String? _error;
  OrderModel? _currentOrder;
  PaymentModel? _currentPayment;
  Map<String, dynamic>? _checkoutRouteExtra;

  List<OrderWithDetails> get orders => _orders;
  List<OrderHistoryModel> get currentOrderHistory => _currentOrderHistory;
  List<ExtraWorkRequest> get extraWorkRequests => _extraWorkRequests;
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
      _currentOrderHistory = await _orderService.getOrderHistory(orderId);
      _extraWorkRequests = await _orderService.getExtraWorkRequests(orderId);
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

            // First, check current payment status (webhook might have already updated it)
            var currentPayment = await _orderService.getPaymentById(_currentPayment!.id);

            // Only update to processing if payment is still unpaid
            // (webhook might have already marked it as paid/failed)
            if (currentPayment.status == PaymentStatus.unpaid) {
              try {
                currentPayment = await _orderService.updatePaymentProcessing(
                  paymentId: _currentPayment!.id,
                  razorpayPaymentId: response.paymentId ?? '',
                  razorpaySignature: response.signature ?? '',
                );
              } catch (_) {
                currentPayment =
                    await _orderService.getPaymentById(_currentPayment!.id);
              }
            }

            // If already paid or failed, use that status immediately
            if (currentPayment.status == PaymentStatus.paid ||
                currentPayment.status == PaymentStatus.failed) {
              _currentPayment = currentPayment;

              if (currentPayment.status == PaymentStatus.paid) {
                onPaymentSuccess(_currentOrder!, currentPayment);
              } else {
                onPaymentError(
                  _currentOrder!,
                  currentPayment,
                  currentPayment.failureReason ?? 'Payment failed',
                );
              }
              return;
            }

            // Wait for webhook to update payment status
            final finalPayment = await _orderService.waitForPaymentResolution(
              paymentId: _currentPayment!.id,
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
          _error = 'Payment failed: ${response.message}';
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

      _isLoading = false;
      notifyListeners();

      try {
        await _orderService.openRazorpay(
          razorpayOrderId: razorpayOrderId,
          amount: request.amount,
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
