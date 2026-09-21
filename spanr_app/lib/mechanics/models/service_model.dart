class ServiceModel {
  final String id;
  final String companyId;
  final String name;
  final String? description;
  final String category; // 'car' or 'bike'
  final String? iconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    required this.category,
    this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Builds a service category from a `job_sections` row — the data model the
  /// mechanic dashboard's live Services page actually writes to.
  factory ServiceModel.fromJobSection(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      description: null,
      category: json['vehicle_type'] as String,
      iconUrl: json['image_url'] as String?,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

