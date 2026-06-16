class StaffUser {
  final String id;
  final String companyId;
  final String email;
  final String name;
  final bool enabled;
  final String? phone;
  final String availability;
  final bool mustChangePassword;

  const StaffUser({
    required this.id,
    required this.companyId,
    required this.email,
    required this.name,
    required this.enabled,
    this.phone,
    this.availability = 'available',
    this.mustChangePassword = false,
  });

  factory StaffUser.fromJson(Map<String, dynamic> json) {
    final profile = json['staff_profiles'];
    final profileMap = profile is List
        ? (profile.isNotEmpty ? profile.first as Map<String, dynamic> : null)
        : profile as Map<String, dynamic>?;

    return StaffUser(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      enabled: json['enabled'] as bool? ?? true,
      phone: json['phone'] as String? ?? profileMap?['phone'] as String?,
      availability: profileMap?['availability'] as String? ?? 'available',
      mustChangePassword: profileMap?['must_change_password'] as bool? ?? false,
    );
  }
}
