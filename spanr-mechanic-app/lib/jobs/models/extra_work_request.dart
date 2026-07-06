class ExtraWorkRequest {
  final String id;
  final String orderId;
  final String? mechanicId;
  final String description;
  final String? photoUrl;
  final double estimatedCost;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionReason;
  final DateTime? customerResponseAt;
  final DateTime createdAt;

  const ExtraWorkRequest({
    required this.id,
    required this.orderId,
    this.mechanicId,
    required this.description,
    this.photoUrl,
    required this.estimatedCost,
    required this.status,
    this.rejectionReason,
    this.customerResponseAt,
    required this.createdAt,
  });

  factory ExtraWorkRequest.fromJson(Map<String, dynamic> json) {
    return ExtraWorkRequest(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      mechanicId: json['mechanic_id'] as String?,
      description: json['description'] as String,
      photoUrl: json['photo_url'] as String?,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      customerResponseAt: json['customer_response_at'] != null
          ? DateTime.parse(json['customer_response_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
