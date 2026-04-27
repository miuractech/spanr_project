class CompanyModel {
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
  final double? rating;
  final List<String> certifications;
  final List<String> specializations;

  CompanyModel({
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
    this.rating,
    this.certifications = const [],
    this.specializations = const [],
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      companyName: json['company_name'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      landmark: json['landmark'],
      city: json['city'],
      state: json['state'],
      phoneNumber: json['phone_number'],
      pincode: json['pincode'],
      phone: json['phone'],
      email: json['email'],
      logo: json['logo'],
      rating: json['rating']?.toDouble(),
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : [],
      specializations: json['specializations'] != null
          ? List<String>.from(json['specializations'])
          : [],
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty ?? false) addressLine2,
      if (landmark?.isNotEmpty ?? false) landmark,
      city,
      state,
      pincode,
    ];
    return parts.join(', ');
  }
}

