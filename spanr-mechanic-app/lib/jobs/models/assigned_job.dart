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
  final int? planDurationMinutes;
  final String? planLocationType;
  final String? planVehicleType;
  final String? planWarranty;
  final String? planGuarantee;
  final String? planType;
  final List<String> planFeatures;
  final List<String> planSteps;
  final List<String> planAdditionalServices;
  final List<String> planJobs;
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

  String get planDurationDisplay {
    final duration = planDurationMinutes ?? 0;
    if (duration <= 0) return '';
    final hours = duration ~/ 60;
    final mins = duration % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours}h';
    return '${mins}m';
  }

  String get planLocationDisplay {
    switch (planLocationType) {
      case 'in_premise':
        return 'In shop';
      case 'shed':
        return 'Doorstep';
      default:
        return planLocationType ?? '';
    }
  }

  bool get hasPlanDetails =>
      planDurationDisplay.isNotEmpty ||
      planLocationDisplay.isNotEmpty ||
      (planWarranty != null && planWarranty!.isNotEmpty) ||
      (planGuarantee != null && planGuarantee!.isNotEmpty) ||
      planJobs.isNotEmpty ||
      planFeatures.isNotEmpty ||
      planSteps.isNotEmpty ||
      planAdditionalServices.isNotEmpty;

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
    this.planDurationMinutes,
    this.planLocationType,
    this.planVehicleType,
    this.planWarranty,
    this.planGuarantee,
    this.planType,
    this.planFeatures = const [],
    this.planSteps = const [],
    this.planAdditionalServices = const [],
    this.planJobs = const [],
    this.specialInstructions,
    required this.scheduledDate,
  });

  AssignedJob copyWith({JobStatus? status}) {
    return AssignedJob(
      orderId: orderId,
      assignmentId: assignmentId,
      status: status ?? this.status,
      assignedAt: assignedAt,
      notes: notes,
      customerName: customerName,
      customerPhone: customerPhone,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
      licensePlate: licensePlate,
      planName: planName,
      planDurationMinutes: planDurationMinutes,
      planLocationType: planLocationType,
      planVehicleType: planVehicleType,
      planWarranty: planWarranty,
      planGuarantee: planGuarantee,
      planType: planType,
      planFeatures: planFeatures,
      planSteps: planSteps,
      planAdditionalServices: planAdditionalServices,
      planJobs: planJobs,
      specialInstructions: specialInstructions,
      scheduledDate: scheduledDate,
    );
  }

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

    final selectedJobs = _jobNames(
      order['order_selected_jobs'],
      nestedCatalog: true,
    );
    final includedJobs = _jobNames(
      plan?['plan_included_jobs'],
      nestedCatalog: true,
    );

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
      planDurationMinutes: plan?['duration'] as int?,
      planLocationType: plan?['location_type'] as String?,
      planVehicleType: plan?['vehicle_type'] as String?,
      planWarranty: plan?['warranty'] as String?,
      planGuarantee: plan?['guarantee'] as String?,
      planType: plan?['plan_type'] as String?,
      planFeatures: _orderedStrings(plan?['plan_features'], 'feature'),
      planSteps: _orderedStrings(plan?['plan_steps'], 'step_description'),
      planAdditionalServices:
          _orderedStrings(plan?['plan_additional_services'], 'service_name'),
      planJobs: selectedJobs.isNotEmpty ? selectedJobs : includedJobs,
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
    'plan_duration_minutes': planDurationMinutes,
    'plan_location_type': planLocationType,
    'plan_vehicle_type': planVehicleType,
    'plan_warranty': planWarranty,
    'plan_guarantee': planGuarantee,
    'plan_type': planType,
    'plan_features': planFeatures,
    'plan_steps': planSteps,
    'plan_additional_services': planAdditionalServices,
    'plan_jobs': planJobs,
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
      planDurationMinutes: json['plan_duration_minutes'] as int?,
      planLocationType: json['plan_location_type'] as String?,
      planVehicleType: json['plan_vehicle_type'] as String?,
      planWarranty: json['plan_warranty'] as String?,
      planGuarantee: json['plan_guarantee'] as String?,
      planType: json['plan_type'] as String?,
      planFeatures: _stringList(json['plan_features']),
      planSteps: _stringList(json['plan_steps']),
      planAdditionalServices: _stringList(json['plan_additional_services']),
      planJobs: _stringList(json['plan_jobs']),
      specialInstructions: json['special_instructions'] as String?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => '$e').where((s) => s.isNotEmpty).toList();
  }

  static List<String> _orderedStrings(dynamic raw, String field) {
    if (raw is! List) return const [];
    final rows = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) =>
          ((a['display_order'] as num?) ?? 0)
              .compareTo((b['display_order'] as num?) ?? 0));
    return rows
        .map((e) => (e[field] as String?)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<String> _jobNames(dynamic raw, {required bool nestedCatalog}) {
    if (raw is! List) return const [];
    final names = <String>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      String? name;
      if (nestedCatalog) {
        final catalog = map['job_catalog'];
        if (catalog is Map) {
          name = catalog['name'] as String?;
        }
      }
      name ??= map['name'] as String?;
      final issue = (map['issue_description'] as String?)?.trim();
      if (name != null && name.isNotEmpty) {
        names.add(issue != null && issue.isNotEmpty ? '$name — $issue' : name);
      }
    }
    return names;
  }
}
