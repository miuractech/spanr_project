import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'order_model.dart';
import 'order_provider.dart';

const _kOrange = Color(0xFFFC8019);
const _kGreen = Color(0xFF267E3E);
const _kHeading = Color(0xFF1C1C1C);
const _kBody = Color(0xFF696969);
const _kBg = Color(0xFFF2F2F2);

class PaymentProcessingScreen extends StatelessWidget {
  final OrderModel order;
  final PaymentModel payment;
  final String status; // 'processing', 'success', 'failed'

  const PaymentProcessingScreen({
    super.key,
    required this.order,
    required this.payment,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: status != 'processing',
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: status != 'processing'
            ? AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: _kHeading),
                title: Text(_getTitle(),
                    style: const TextStyle(
                        color: _kHeading, fontWeight: FontWeight.w700, fontSize: 18)),
              )
            : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusWidget(),
                const SizedBox(height: 32),
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _kHeading,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _getMessage(),
                  style: const TextStyle(
                    color: _kBody,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (status == 'failed') ...[
                  const SizedBox(height: 32),
                  if (payment.failureReason != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              payment.failureReason!,
                              style: TextStyle(
                                  color: Colors.red.shade900, fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final extra =
                          context.read<OrderProvider>().checkoutRouteExtra;
                      if (extra != null) {
                        context.go('/checkout', extra: extra);
                      } else {
                        context.go('/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Try Again',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kOrange,
                      side: const BorderSide(color: _kOrange, width: 1.5),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Back to Home',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget() {
    switch (status) {
      case 'processing':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _kOrange.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(strokeWidth: 4, color: _kOrange),
            ),
          ),
        );
      case 'success':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _kGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: _kGreen, size: 72),
        );
      case 'failed':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cancel_rounded, color: Colors.red, size: 72),
        );
      default:
        return const SizedBox();
    }
  }

  String _getTitle() {
    switch (status) {
      case 'processing':
        return 'Processing Payment';
      case 'success':
        return 'Payment Successful';
      case 'failed':
        return 'Payment Failed';
      default:
        return 'Payment Status';
    }
  }

  String _getMessage() {
    switch (status) {
      case 'processing':
        return 'Please wait while we verify your payment.\nThis may take a few moments.';
      case 'success':
        return 'Your payment has been successfully processed.\nRedirecting to confirmation...';
      case 'failed':
        return 'Your payment could not be processed.\nPlease try again or use a different payment method.';
      default:
        return '';
    }
  }
}
