class PlanModel {
  final String id;
  final String serviceId;
  final String companyId;
  final String name;
  final String vehicleType; // 'car' or 'bike'
  final String locationType; // 'in_premise' or 'shed'
  final int duration; // in minutes
  final double basePrice;
  final double tax;
  final String? warranty;
  final String? guarantee;
  final String? badge;
  final List<String> fuelTypes;
  final List<String> features;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlanModel({
    required this.id,
    required this.serviceId,
    required this.companyId,
    required this.name,
    required this.vehicleType,
    required this.locationType,
    required this.duration,
    required this.basePrice,
    required this.tax,
    this.warranty,
    this.guarantee,
    this.badge,
    this.fuelTypes = const [],
    this.features = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      vehicleType: json['vehicle_type'] as String,
      locationType: json['location_type'] as String,
      duration: json['duration'] as int,
      basePrice: (json['base_price'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      warranty: json['warranty'] as String?,
      guarantee: json['guarantee'] as String?,
      badge: json['badge'] as String?,
      fuelTypes: json['fuel_types'] != null
          ? List<String>.from(json['fuel_types'])
          : [],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  double get totalPrice => basePrice * (1 + tax / 100);

  String get durationDisplay {
    final hours = duration ~/ 60;
    final mins = duration % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}

