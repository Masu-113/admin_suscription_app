class PaymentMethod {
  int? id;

  String type;

  String? details;

  PaymentMethod({this.id, required this.type, this.details});

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'details': details};
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],

      type: map['type'],

      details: map['details'],
    );
  }
}
