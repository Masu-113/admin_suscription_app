import 'package:admin_suscription_app/models/billing_cycle.dart';

class Subscription {
  final int? id;

  final int? cloudId;

  final String serviceName;

  final double cost;

  final DateTime startDate;

  final BillingCycle billingCycle;

  final String status;

  final int isCancelled;

  final int? categoryId;

  final int? paymentMethodId;

  final String? userId;

  Subscription({
    this.id,
    this.cloudId,
    required this.serviceName,
    required this.cost,
    required this.startDate,
    required this.billingCycle,
    required this.status,
    this.isCancelled = 0,
    this.categoryId,
    this.paymentMethodId,
    this.userId,
  });

  bool get isCancelledBool => isCancelled == 1;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cloud_id': cloudId,
      'service_name': serviceName,
      'cost': cost,
      'start_date': startDate.toIso8601String(),
      'billing_cycle': billingCycle.name,
      'status': status,
      'isCancelled': isCancelled,
      'category_id': categoryId,
      'payment_method_id': paymentMethodId,
      'user_id': userId,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as int?,
      cloudId: map['cloud_id'] as int?,
      serviceName: map['service_name'] as String,
      cost: (map['cost'] as num).toDouble(),
      startDate: DateTime.parse(map['start_date'] as String),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == map['billing_cycle'],
        orElse: () => BillingCycle.monthly,
      ),
      status: map['status'] as String,
      isCancelled: map['isCancelled'] as int? ?? 0,
      categoryId: map['category_id'] as int?,
      paymentMethodId: map['payment_method_id'] as int?,
      userId: map['user_id'] as String?,
    );
  }
}
