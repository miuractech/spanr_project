class MechanicCompany {
  final String id;
  final String companyName;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String phoneNumber;
  final String pincode;
  final String phone;
  final String email;
  final String? logo;
  final double? latitude;
  final double? longitude;
  final List<String>? images;
  
  // Ratings
  final int? ratingsCount;
  final double? professionalism;
  final double? timeliness;
  final double? quality;
  final double? rating;
  
  // Distance from user location (in km)
  final double? distanceKm;

  final DateTime createdAt;
  final DateTime updatedAt;

  MechanicCompany({
    required this.id,
    required this.companyName,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.phoneNumber,
    required this.pincode,
    required this.phone,
    required this.email,
    this.logo,
    this.latitude,
    this.longitude,
    this.images,
    this.ratingsCount,
    this.professionalism,
    this.timeliness,
    this.quality,
    this.rating,
    this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MechanicCompany.fromJson(Map<String, dynamic> json) {
    return MechanicCompany(
      id: json['id'] as String,
      companyName: json['company_name'] as String,
      addressLine1: json['address_line_1'] as String,
      addressLine2: json['address_line_2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      phoneNumber: json['phone_number'] as String,
      pincode: json['pincode'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      logo: json['logo'] as String?,
      latitude: json['latitude'] != null 
          ? (json['latitude'] as num).toDouble() 
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      images: json['images'] != null 
          ? List<String>.from(json['images'] as List)
          : null,
      ratingsCount: json['ratings_count'] as int?,
      professionalism: json['professionalism'] != null
          ? (json['professionalism'] as num).toDouble()
          : null,
      timeliness: json['timeliness'] != null
          ? (json['timeliness'] as num).toDouble()
          : null,
      quality: json['quality'] != null
          ? (json['quality'] as num).toDouble()
          : null,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      if (landmark != null && landmark!.isNotEmpty) landmark,
      city,
      state,
      pincode,
    ];
    return parts.join(', ');
  }

  String get displayRating {
    if (rating == null || ratingsCount == null || ratingsCount == 0) {
      return 'New';
    }
    return '${rating!.toStringAsFixed(1)} (${ratingsCount})';
  }
  
  String get displayDistance {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toStringAsFixed(0)}m away';
    }
    return '${distanceKm!.toStringAsFixed(1)}km away';
  }

  /// Logo if set; otherwise first company image (for avatars / hero fallback).
  String? get brandImageUrl =>
      logo ??
      (images != null && images!.isNotEmpty ? images!.first : null);
  
  MechanicCompany copyWith({
    double? distanceKm,
  }) {
    return MechanicCompany(
      id: id,
      companyName: companyName,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      landmark: landmark,
      city: city,
      state: state,
      phoneNumber: phoneNumber,
      pincode: pincode,
      phone: phone,
      email: email,
      logo: logo,
      latitude: latitude,
      longitude: longitude,
      images: images,
      ratingsCount: ratingsCount,
      professionalism: professionalism,
      timeliness: timeliness,
      quality: quality,
      rating: rating,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

