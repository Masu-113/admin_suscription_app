class Subscription {
  int? id;

  String serviceName;

  double cost;

  DateTime renewalDate;

  String status;

  int? categoryId;

  int? paymentMethodId;

  Subscription({
    this.id,

    required this.serviceName,

    required this.cost,

    required this.renewalDate,

    required this.status,

    this.categoryId,

    this.paymentMethodId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'service_name': serviceName,

      'cost': cost,

      'renewal_date': renewalDate.toIso8601String(),

      'status': status,

      'category_id': categoryId,

      'payment_method_id': paymentMethodId,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],

      serviceName: map['service_name'],

      cost: map['cost'],

      renewalDate: DateTime.parse(map['renewal_date']),

      status: map['status'],

      categoryId: map['category_id'],

      paymentMethodId: map['payment_method_id'],
    );
  }
}
