class VehicleModel {
  final String id;
  final String userId;
  final String? name;
  final String make;
  final String model;
  final int year;
  final String? color;
  final String licensePlate;
  final String vehicleType;
  final bool isPrimary;
  final bool isIndianLicensed;
  final DateTime createdAt;
  final List<String> images;

  VehicleModel({
    required this.id,
    required this.userId,
    this.name,
    required this.make,
    required this.model,
    required this.year,
    this.color,
    required this.licensePlate,
    required this.vehicleType,
    this.isPrimary = false,
    this.isIndianLicensed = true,
    required this.createdAt,
    this.images = const [],
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    if (json['images'] != null) {
      imageUrls = (json['images'] as List)
          .map((img) => img['url'].toString())
          .toList();
    }

    return VehicleModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      licensePlate: json['license_plate'],
      vehicleType: json['vehicle_type'] ?? 'car',
      isPrimary: json['is_primary'] ?? false,
      isIndianLicensed: json['is_indian_licensed'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      images: imageUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'vehicle_type': vehicleType,
      'is_primary': isPrimary,
      'is_indian_licensed': isIndianLicensed,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    String? vehicleType,
    bool? isPrimary,
    bool? isIndianLicensed,
    DateTime? createdAt,
    List<String>? images,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      isPrimary: isPrimary ?? this.isPrimary,
      isIndianLicensed: isIndianLicensed ?? this.isIndianLicensed,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
    );
  }
}

