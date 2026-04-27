import 'order_types.dart';
import '../vehicles/models/vehicle_model.dart';
import '../mechanics/models/plan_model.dart';
import '../mechanics/models/service_model.dart';

class OrderModel {
  final String id;
  final String companyId;
  final String userId;
  final String planId;
  final String vehicleId;
  final DateTime orderDate;
  final DateTime scheduledServiceDate;
  final OrderStatus status;
  final String? specialInstructions;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String contactAddress;
  final double serviceLatitude;
  final double serviceLongitude;
  final String serviceAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.planId,
    required this.vehicleId,
    required this.orderDate,
    required this.scheduledServiceDate,
    required this.status,
    this.specialInstructions,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.contactAddress,
    required this.serviceLatitude,
    required this.serviceLongitude,
    required this.serviceAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      scheduledServiceDate:
          DateTime.parse(json['scheduled_service_date'] as String),
      status: OrderStatus.fromDbValue(json['status'] as String),
      specialInstructions: json['special_instructions'] as String?,
      contactName: json['contact_name'] as String,
      contactPhone: json['contact_phone'] as String,
      contactEmail: json['contact_email'] as String,
      contactAddress: json['contact_address'] as String,
      serviceLatitude: (json['service_latitude'] as num).toDouble(),
      serviceLongitude: (json['service_longitude'] as num).toDouble(),
      serviceAddress: json['service_address'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'user_id': userId,
      'plan_id': planId,
      'vehicle_id': vehicleId,
      'order_date': orderDate.toIso8601String(),
      'scheduled_service_date': scheduledServiceDate.toIso8601String(),
      'status': status.dbValue,
      'special_instructions': specialInstructions,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'contact_address': contactAddress,
      'service_latitude': serviceLatitude,
      'service_longitude': serviceLongitude,
      'service_address': serviceAddress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderHistoryModel {
  final String id;
  final String orderId;
  final OrderStatus status;
  final String? notes;
  final String? changedBy;
  final DateTime createdAt;

  OrderHistoryModel({
    required this.id,
    required this.orderId,
    required this.status,
    this.notes,
    this.changedBy,
    required this.createdAt,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      status: OrderStatus.fromDbValue(json['status'] as String),
      notes: json['notes'] as String?,
      changedBy: json['changed_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'status': status.dbValue,
      'notes': notes,
      'changed_by': changedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PaymentModel {
  final String id;
  final String orderId;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String? transactionId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? failureReason;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.method,
    required this.status,
    required this.amount,
    this.transactionId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.failureReason,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      method: PaymentMethod.fromDbValue(json['method'] as String),
      status: PaymentStatus.fromDbValue(json['status'] as String),
      amount: (json['amount'] as num).toDouble(),
      transactionId: json['transaction_id'] as String?,
      razorpayOrderId: json['razorpay_order_id'] as String?,
      razorpayPaymentId: json['razorpay_payment_id'] as String?,
      razorpaySignature: json['razorpay_signature'] as String?,
      failureReason: json['failure_reason'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'method': method.dbValue,
      'status': status.dbValue,
      'amount': amount,
      'transaction_id': transactionId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'failure_reason': failureReason,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreateOrderRequest {
  final String companyId;
  final String userId;
  final String planId;
  final String vehicleId;
  final DateTime scheduledServiceDate;
  final String? specialInstructions;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String contactAddress;
  final double serviceLatitude;
  final double serviceLongitude;
  final String serviceAddress;
  final double amount;
  final List<String> beforeImageUrls;

  CreateOrderRequest({
    required this.companyId,
    required this.userId,
    required this.planId,
    required this.vehicleId,
    required this.scheduledServiceDate,
    this.specialInstructions,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.contactAddress,
    required this.serviceLatitude,
    required this.serviceLongitude,
    required this.serviceAddress,
    required this.amount,
    required this.beforeImageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'user_id': userId,
      'plan_id': planId,
      'vehicle_id': vehicleId,
      'scheduled_service_date': scheduledServiceDate.toIso8601String(),
      'special_instructions': specialInstructions,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'contact_address': contactAddress,
      'service_latitude': serviceLatitude,
      'service_longitude': serviceLongitude,
      'service_address': serviceAddress,
      'status': OrderStatus.created.dbValue,
      'order_date': DateTime.now().toIso8601String(),
    };
  }
}

class OrderWithDetails {
  final OrderModel order;
  final VehicleModel? vehicle;
  final PlanModel? plan;
  final ServiceModel? service;
  final PaymentModel? payment;

  OrderWithDetails({
    required this.order,
    this.vehicle,
    this.plan,
    this.service,
    this.payment,
  });

  factory OrderWithDetails.fromJson(Map<String, dynamic> json) {
    return OrderWithDetails(
      order: OrderModel.fromJson(json),
      vehicle: json['vehicles'] != null
          ? VehicleModel.fromJson(json['vehicles'])
          : null,
      plan: json['plans'] != null 
          ? PlanModel.fromJson(json['plans'])
          : null,
      service: json['services'] != null
          ? ServiceModel.fromJson(json['services'])
          : null,
      payment: json['payments'] != null && (json['payments'] is List && (json['payments'] as List).isNotEmpty)
          ? PaymentModel.fromJson((json['payments'] as List).first)
          : (json['payments'] != null && json['payments'] is Map)
              ? PaymentModel.fromJson(json['payments'])
              : null,
    );
  }
}

