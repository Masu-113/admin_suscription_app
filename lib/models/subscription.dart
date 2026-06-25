class Subscription {
  int? id;
  String serviceName;
  double cost;
  DateTime renewalDate;
  String status;

  Subscription({
    this.id,
    required this.serviceName,
    required this.cost,
    required this.renewalDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'service_name': serviceName,
      'cost': cost,
      'renewal_date': renewalDate.toIso8601String(),
      'status': status,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      serviceName: map['service_name'],
      cost: map['cost'],
      renewalDate: DateTime.parse(map['renewal_date']),
      status: map['status'],
    );
  }
}
