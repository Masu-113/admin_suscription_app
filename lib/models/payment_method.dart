class PaymentMethod {
  int id;
  String type;
  String? details;

  PaymentMethod({required this.id, required this.type, this.details});

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'details': details};
  }
}
