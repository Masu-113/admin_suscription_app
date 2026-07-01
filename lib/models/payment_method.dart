class PaymentMethod {
  final int? id;

  final String type;

  final String? details;

  final int? userId;

  PaymentMethod({this.id, required this.type, this.details, this.userId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'details': details, 'user_id': userId};
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'] as int?,

      type: map['type'] as String,

      details: map['details'] as String?,

      userId: map['user_id'] as int?,
    );
  }
}
