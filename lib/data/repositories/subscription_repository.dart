import 'package:admin_suscription_app/models/subscription_full.dart';
import '../local/database_helper.dart';
import '../../models/subscription.dart';

class SubscriptionRepository {
  final dbHelper = DatabaseHelper();

  // INSERTAR SUSCRIPCIÓN
  Future<void> insertSubscription(Subscription sub) async {
    final db = await dbHelper.database;

    await db.insert('subscriptions', sub.toMap());
  }

  // OBTENER SUSCRIPCIONES BÁSICAS
  Future<List<Subscription>> getSubscriptions() async {
    final db = await dbHelper.database;

    final result = await db.query('subscriptions');

    return result.map((map) {
      return Subscription(
        id: map['id'] as int?,
        serviceName: (map['service_name'] ?? '') as String,
        cost: (map['cost'] as num).toDouble(),
        renewalDate: DateTime.parse(map['renewal_date'] as String),
        status: (map['status'] ?? 'Active') as String,
        categoryId: map['category_id'] as int?,
        paymentMethodId: map['payment_method_id'] as int?,
      );
    }).toList();
  }

  // OBTENER SUSCRIPCIONES CON NOMBRES (JOIN MANUAL)
  Future<List<SubscriptionFull>> getSubscriptionsFull() async {
    final db = await dbHelper.database;

    final subs = await db.query('subscriptions');
    final categories = await db.query('categories');
    final payments = await db.query('payment_methods');

    return subs.map((s) {
      final sub = Subscription(
        id: s['id'] as int?,
        serviceName: s['service_name'] as String,
        cost: (s['cost'] as num).toDouble(),
        renewalDate: DateTime.parse(s['renewal_date'] as String),
        status: s['status'] as String,
        categoryId: s['category_id'] as int?,
        paymentMethodId: s['payment_method_id'] as int?,
      );
      // CATEGORY NAME (SAFE CAST)
      final categoryName =
          (categories.firstWhere(
                (c) => c['id'] == sub.categoryId,
                orElse: () => {'name': 'Unknown'},
              )['name']
              as String);
      // PAYMENT NAME (SAFE CAST)
      final paymentName =
          (payments.firstWhere(
                (p) => p['id'] == sub.paymentMethodId,
                orElse: () => {'type': 'Unknown'},
              )['type']
              as String);

      return SubscriptionFull(
        subscription: sub,
        categoryName: categoryName,
        paymentMethodName: paymentName,
      );
    }).toList();
  }

  // ELIMINAR SUSCRIPCIÓN
  Future<void> deleteSubscription(int id) async {
    final db = await dbHelper.database;

    await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // ACTUALIZAR SUSCRIPCIÓN
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
