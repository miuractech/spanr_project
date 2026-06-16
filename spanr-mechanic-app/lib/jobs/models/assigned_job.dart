import 'job_status.dart';

class AssignedJob {
  final String orderId;
  final String assignmentId;
  final JobStatus status;
  final DateTime assignedAt;
  final String? notes;
  final String customerName;
  final String? customerPhone;
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final String licensePlate;
  final String planName;
  final String? specialInstructions;
  final DateTime scheduledDate;

  String get vehicleDisplay {
    final parts = <String>[
      if (vehicleMake.isNotEmpty) vehicleMake,
      if (vehicleModel.isNotEmpty) vehicleModel,
    ];
    if (parts.isEmpty) {
      return licensePlate.isNotEmpty ? licensePlate : 'Vehicle details unavailable';
    }
    final name = parts.join(' ');
    if (vehicleYear > 0) return '$name · $vehicleYear';
    return name;
  }

  const AssignedJob({
    required this.orderId,
    required this.assignmentId,
    required this.status,
    required this.assignedAt,
    this.notes,
    required this.customerName,
    this.customerPhone,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.licensePlate,
    required this.planName,
    this.specialInstructions,
    required this.scheduledDate,
  });

  factory AssignedJob.fromJson(Map<String, dynamic> json) {
    final order = json['orders'] as Map<String, dynamic>;
    final user = order['users'] as Map<String, dynamic>?;
    Map<String, dynamic>? vehicle;
    final vehicleRaw = order['vehicles'];
    if (vehicleRaw is Map<String, dynamic>) {
      vehicle = vehicleRaw;
    } else if (vehicleRaw is List && vehicleRaw.isNotEmpty) {
      vehicle = vehicleRaw.first as Map<String, dynamic>;
    }
    final plan = order['plans'] as Map<String, dynamic>?;

    return AssignedJob(
      orderId: json['order_id'] as String,
      assignmentId: json['id'] as String,
      status: JobStatus.fromDb(order['status'] as String? ?? 'assigned'),
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      notes: json['notes'] as String?,
      customerName: user?['name'] as String? ?? order['contact_name'] as String? ?? 'Customer',
      customerPhone: user?['phone'] as String? ?? order['contact_phone'] as String?,
      vehicleMake: vehicle?['make'] as String? ?? '',
      vehicleModel: vehicle?['model'] as String? ?? '',
      vehicleYear: vehicle?['year'] as int? ?? 0,
      licensePlate: vehicle?['license_plate'] as String? ?? '',
      planName: plan?['name'] as String? ?? 'Service',
      specialInstructions: order['special_instructions'] as String?,
      scheduledDate: DateTime.parse(order['scheduled_service_date'] as String),
    );
  }

  Map<String, dynamic> toCacheJson() => {
    'order_id': orderId,
    'assignment_id': assignmentId,
    'status': status.toDb(),
    'assigned_at': assignedAt.toIso8601String(),
    'notes': notes,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'vehicle_make': vehicleMake,
    'vehicle_model': vehicleModel,
    'vehicle_year': vehicleYear,
    'license_plate': licensePlate,
    'plan_name': planName,
    'special_instructions': specialInstructions,
    'scheduled_date': scheduledDate.toIso8601String(),
  };

  factory AssignedJob.fromCacheJson(Map<String, dynamic> json) {
    return AssignedJob(
      orderId: json['order_id'] as String,
      assignmentId: json['assignment_id'] as String,
      status: JobStatus.fromDb(json['status'] as String),
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      notes: json['notes'] as String?,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      vehicleMake: json['vehicle_make'] as String,
      vehicleModel: json['vehicle_model'] as String,
      vehicleYear: json['vehicle_year'] as int,
      licensePlate: json['license_plate'] as String,
      planName: json['plan_name'] as String,
      specialInstructions: json['special_instructions'] as String?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
    );
  }
}
