import 'billing_cycle.dart';

class Subscription {
  int? id;

  String serviceName;

  double cost;

  DateTime startDate;

  BillingCycle billingCycle;

  String status;

  int? categoryId;

  int? paymentMethodId;

  bool isCancelled;

  Subscription({
    this.id,
    required this.serviceName,
    required this.cost,
    required this.startDate,
    required this.billingCycle,
    required this.status,
    this.categoryId,
    this.paymentMethodId,
    this.isCancelled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_name': serviceName,
      'cost': cost,
      'start_date': startDate.toIso8601String(),
      'billing_cycle': billingCycle.name,
      'status': status,
      'category_id': categoryId,
      'payment_method_id': paymentMethodId,
      'isCancelled': isCancelled ? 1 : 0,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      serviceName: map['service_name'],
      cost: map['cost'],
      startDate: DateTime.parse(map['start_date']),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == map['billing_cycle'],
        orElse: () => BillingCycle.monthly,
      ),
      status: map['status'],
      categoryId: map['category_id'],
      paymentMethodId: map['payment_method_id'],
      isCancelled: map['isCancelled'] == 1,
    );
  }
}
