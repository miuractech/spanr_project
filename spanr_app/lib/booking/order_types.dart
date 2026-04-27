enum OrderStatus {
  created,
  accepted,
  inProgress,
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
      case 'ready_for_delivery':
        return OrderStatus.readyForDelivery;
      case 'completed':
        return OrderStatus.completed;
      case 'dispute':
        return OrderStatus.dispute;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        throw ArgumentError('Unknown order status: $value');
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

