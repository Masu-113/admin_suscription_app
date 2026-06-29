import 'package:admin_suscription_app/models/billing_cycle.dart';
import 'package:admin_suscription_app/models/subscription_full.dart';
import '../local/database_helper.dart';
import '../../models/subscription.dart';

class SubscriptionRepository {
  final dbHelper = DatabaseHelper();

  // 🟢 INSERTAR SUSCRIPCIÓN
  Future<int> insertSubscription(Subscription sub) async {
    final db = await dbHelper.database;

    final id = await db.insert('subscriptions', sub.toMap());

    return id;
  }

  // 🟢 OBTENER BÁSICAS
  Future<List<Subscription>> getSubscriptions() async {
    final db = await dbHelper.database;

    final result = await db.query('subscriptions');

    return result.map((map) {
      return Subscription(
        id: map['id'] as int?,
        serviceName: (map['service_name'] ?? '') as String,
        cost: (map['cost'] as num).toDouble(),

        startDate: DateTime.parse(map['start_date'] as String),

        billingCycle: BillingCycle.values.firstWhere(
          (e) => e.name == map['billing_cycle'],
          orElse: () => BillingCycle.monthly,
        ),

        status: (map['status'] ?? 'Active') as String,
        categoryId: map['category_id'] as int?,
        paymentMethodId: map['payment_method_id'] as int?,
      );
    }).toList();
  }

  // 🟢 FULL (JOIN MANUAL)
  Future<List<SubscriptionFull>> getSubscriptionsFull() async {
    final db = await dbHelper.database;

    final subs = await db.query('subscriptions');
    final categories = await db.query('categories');
    final payments = await db.query('payment_methods');

    return subs.map((s) {
      final sub = Subscription(
        id: s['id'] as int?,
        serviceName: (s['service_name'] ?? '') as String,
        cost: (s['cost'] as num).toDouble(),

        startDate: DateTime.parse(s['start_date'] as String),

        billingCycle: BillingCycle.values.firstWhere(
          (e) => e.name == s['billing_cycle'],
          orElse: () => BillingCycle.monthly,
        ),

        status: (s['status'] ?? 'Active') as String,
        categoryId: s['category_id'] as int?,
        paymentMethodId: s['payment_method_id'] as int?,
      );

      // 🟢 CATEGORY NAME SAFE
      final categoryName =
          categories.firstWhere(
                (c) => c['id'] == sub.categoryId,
                orElse: () => {'name': 'Unknown'},
              )['name']
              as String;

      // 🟢 PAYMENT NAME SAFE
      final paymentName =
          payments.firstWhere(
                (p) => p['id'] == sub.paymentMethodId,
                orElse: () => {'type': 'Unknown'},
              )['type']
              as String;

      return SubscriptionFull(
        subscription: sub,
        categoryName: categoryName,
        paymentMethodName: paymentName,
      );
    }).toList();
  }

  // 🟢 DELETE
  Future<void> deleteSubscription(int id) async {
    final db = await dbHelper.database;

    await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // 🟢 UPDATE
  Future<void> updateSubscription(Subscription sub) async {
    final db = await dbHelper.database;

    await db.update(
      'subscriptions',
      sub.toMap(),
      where: 'id = ?',
      whereArgs: [sub.id],
    );
  }
}
