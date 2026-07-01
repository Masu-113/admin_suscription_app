import 'package:admin_suscription_app/models/billing_cycle.dart';
import 'package:admin_suscription_app/models/subscription_full.dart';

import '../local/database_helper.dart';
import '../../models/subscription.dart';

import 'subscription_history_repository.dart';
import '../../models/subscription_history.dart';

class SubscriptionRepository {
  final dbHelper = DatabaseHelper();

  final SubscriptionHistoryRepository _historyRepo =
      SubscriptionHistoryRepository();

  // INSERTAR SUSCRIPCIÓN

  Future<int> insertSubscription(Subscription sub) async {
    final db = await dbHelper.database;

    final id = await db.insert('subscriptions', sub.toMap());

    await _historyRepo.insertHistory(
      SubscriptionHistory(
        subscriptionId: id,

        action: "CREATED",

        actionDate: DateTime.now(),
      ),
    );

    return id;
  }

  // OBTENER BÁSICAS

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

        isCancelled: map['isCancelled'] == 1,

        categoryId: map['category_id'] as int?,

        paymentMethodId: map['payment_method_id'] as int?,

        userId: map['user_id'] as int?,
      );
    }).toList();
  }

  // FULL

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

        isCancelled: s['isCancelled'] == 1,

        categoryId: s['category_id'] as int?,

        paymentMethodId: s['payment_method_id'] as int?,

        userId: s['user_id'] as int?,
      );

      final categoryName =
          categories.firstWhere(
                (c) => c['id'] == sub.categoryId,

                orElse: () => {'name': 'Unknown'},
              )['name']
              as String;

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

  // FULL POR USUARIO

  Future<List<SubscriptionFull>> getSubscriptionsFullByUser(int userId) async {
    final db = await dbHelper.database;

    final subs = await db.query(
      'subscriptions',

      where: 'user_id = ?',

      whereArgs: [userId],
    );

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

        isCancelled: s['isCancelled'] == 1,

        categoryId: s['category_id'] as int?,

        paymentMethodId: s['payment_method_id'] as int?,

        userId: s['user_id'] as int?,
      );

      final categoryName =
          categories.firstWhere(
                (c) => c['id'] == sub.categoryId,

                orElse: () => {'name': 'Unknown'},
              )['name']
              as String;

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

  // CANCELAR

  Future<void> cancelSubscription(int id) async {
    final db = await dbHelper.database;

    await db.update(
      'subscriptions',

      {'isCancelled': 1},

      where: 'id = ?',

      whereArgs: [id],
    );

    await _historyRepo.insertHistory(
      SubscriptionHistory(
        subscriptionId: id,

        action: "CANCELLED",

        actionDate: DateTime.now(),
      ),
    );
  }

  // REACTIVAR

  Future<void> restoreSubscription(int id) async {
    final db = await dbHelper.database;

    await db.update(
      'subscriptions',

      {'isCancelled': 0},

      where: 'id = ?',

      whereArgs: [id],
    );

    await _historyRepo.insertHistory(
      SubscriptionHistory(
        subscriptionId: id,

        action: "RESTORED",

        actionDate: DateTime.now(),
      ),
    );
  }

  // UPDATE

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
