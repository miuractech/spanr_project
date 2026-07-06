enum OrderStatus {
  created,
  accepted,
  inProgress,
  onHold,
  readyForDelivery,
  completed,
  dispute,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.created:
        return 'Created';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.onHold:
        return 'On Hold — Awaiting Approval';
      case OrderStatus.readyForDelivery:
        return 'Ready for Delivery';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.dispute:
        return 'Dispute';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get dbValue {
    switch (this) {
      case OrderStatus.created:
        return 'created';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.onHold:
        return 'on_hold';
      case OrderStatus.readyForDelivery:
        return 'ready_for_delivery';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.dispute:
        return 'dispute';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromDbValue(String value) {
    switch (value) {
      case 'created':
        return OrderStatus.created;
      case 'accepted':
        return OrderStatus.accepted;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'on_hold':
        return OrderStatus.onHold;
      case 'ready_for_delivery':
        return OrderStatus.readyForDelivery;
      case 'completed':
        return OrderStatus.completed;
      case 'dispute':
        return OrderStatus.dispute;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.created;
    }
  }
}

enum PaymentMethod {
  creditCard,
  debitCard,
  netBanking,
  upi;

  String get dbValue {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.debitCard:
        return 'debit_card';
      case PaymentMethod.netBanking:
        return 'net_banking';
      case PaymentMethod.upi:
        return 'upi';
    }
  }

  static PaymentMethod fromDbValue(String value) {
    switch (value) {
      case 'credit_card':
        return PaymentMethod.creditCard;
      case 'debit_card':
        return PaymentMethod.debitCard;
      case 'net_banking':
        return PaymentMethod.netBanking;
      case 'upi':
        return PaymentMethod.upi;
      default:
        throw ArgumentError('Unknown payment method: $value');
    }
  }
}

enum PaymentStatus {
  unpaid,
  processing,
  paid,
  failed;

  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  String get dbValue {
    switch (this) {
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.unpaid:
        return 'unpaid';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.failed:
        return 'failed';
    }
  }

  static PaymentStatus fromDbValue(String value) {
    switch (value) {
      case 'paid':
        return PaymentStatus.paid;
      case 'unpaid':
        return PaymentStatus.unpaid;
      case 'processing':
        return PaymentStatus.processing;
      case 'failed':
        return PaymentStatus.failed;
      default:
        throw ArgumentError('Unknown payment status: $value');
    }
  }
}

class ExtraWorkRequest {
  final String id;
  final String orderId;
  final String? mechanicId;
  final String description;
  final String? photoUrl;
  final double estimatedCost;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionReason;
  final DateTime? customerResponseAt;
  final DateTime createdAt;

  const ExtraWorkRequest({
    required this.id,
    required this.orderId,
    this.mechanicId,
    required this.description,
    this.photoUrl,
    required this.estimatedCost,
    required this.status,
    this.rejectionReason,
    this.customerResponseAt,
    required this.createdAt,
  });

  factory ExtraWorkRequest.fromJson(Map<String, dynamic> json) {
    return ExtraWorkRequest(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      mechanicId: json['mechanic_id'] as String?,
      description: json['description'] as String,
      photoUrl: json['photo_url'] as String?,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      customerResponseAt: json['customer_response_at'] != null
          ? DateTime.parse(json['customer_response_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
