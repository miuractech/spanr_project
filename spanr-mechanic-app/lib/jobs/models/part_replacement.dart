class PartReplacement {
  final String? id;
  final String partName;
  final String? partNumber;
  final String? brand;
  final int quantity;
  final double? cost;
  final String? beforePhotoUrl;
  final String? photoUrl;
  final int? kmReading;

  const PartReplacement({
    this.id,
    required this.partName,
    this.partNumber,
    this.brand,
    this.quantity = 1,
    this.cost,
    this.beforePhotoUrl,
    this.photoUrl,
    this.kmReading,
  });

  factory PartReplacement.fromJson(Map<String, dynamic> json) {
    return PartReplacement(
      id: json['id'] as String?,
      partName: json['part_name'] as String,
      partNumber: json['part_number'] as String?,
      brand: json['brand'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      cost: (json['cost'] as num?)?.toDouble(),
      beforePhotoUrl: json['before_photo_url'] as String?,
      photoUrl: json['photo_url'] as String?,
      kmReading: json['km_reading'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'part_name': partName,
    'part_number': partNumber,
    'brand': brand,
    'quantity': quantity,
    'cost': cost,
    'before_photo_url': beforePhotoUrl,
    'photo_url': photoUrl,
    'km_reading': kmReading,
  };
}
