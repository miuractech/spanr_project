import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'order_model.dart';

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
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: status != 'processing',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: status != 'processing'
            ? AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: Text(_getTitle()),
              )
            : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusWidget(context, primary),
                const SizedBox(height: 32),
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _getMessage(),
                  style: TextStyle(
                    color: Colors.grey[500],
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
                    onPressed: () => context.go('/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Try Again',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Home',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context, Color primary) {
    switch (status) {
      case 'processing':
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(strokeWidth: 4, color: primary),
            ),
          ),
        );
      case 'success':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 72),
        );
      case 'failed':
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
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
