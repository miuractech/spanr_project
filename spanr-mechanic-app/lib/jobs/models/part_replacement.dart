class PartReplacement {
  final String? id;
  final String partName;
  final String? partNumber;
  final String? brand;
  final int quantity;
  final double? cost;
  final String? photoUrl;
  final int? kmReading;

  const PartReplacement({
    this.id,
    required this.partName,
    this.partNumber,
    this.brand,
    this.quantity = 1,
    this.cost,
    this.photoUrl,
    this.kmReading,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'part_name': partName,
    'part_number': partNumber,
    'brand': brand,
    'quantity': quantity,
    'cost': cost,
    'photo_url': photoUrl,
    'km_reading': kmReading,
  };
}
