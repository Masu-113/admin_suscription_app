class PaymentMethod {
  final int? id;
  final int? cloudId;
  final String type;
  final String? details;
  final String? userId;

  PaymentMethod({
    this.id,
    this.cloudId,
    required this.type,
    this.details,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'type': type,
      'details': details,
      'user_id': userId,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      type: map['type'] as String,
      details: map['details'] as String?,
      userId: map['user_id'] as String?,
    );
  }
}
