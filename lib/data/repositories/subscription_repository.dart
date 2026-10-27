//import 'package:admin_suscription_app/models/billing_cycle.dart';
import 'package:admin_suscription_app/models/subscription_full.dart';

import '../local/database_helper.dart';
import '../../models/subscription.dart';

import 'subscription_history_repository.dart';
import '../../models/subscription_history.dart';

import '../repositories/supabase_repository.dart';
import 'category_repository.dart';
import 'payment_method_repository.dart';
import 'package:flutter/foundation.dart';

class SubscriptionRepository {
  final dbHelper = DatabaseHelper();

  final SupabaseRepository _supabase = SupabaseRepository();

  final CategoryRepository _categoryRepo = CategoryRepository();

  final PaymentMethodRepository _paymentRepo = PaymentMethodRepository();

  final SubscriptionHistoryRepository _historyRepo =
      SubscriptionHistoryRepository();

  // INSERTAR SUSCRIPCIÓN

  Future<int> insertSubscription(Subscription sub) async {
    final db = await dbHelper.database;

    int? cloudCategoryId;
    int? cloudPaymentMethodId;

    if (sub.categoryId != null) {
      final category = await _categoryRepo.getCategoryByLocalId(
        sub.categoryId!,
      );
      cloudCategoryId = category?.cloudId;
    }

    if (sub.paymentMethodId != null) {
      final payment = await _paymentRepo.getPaymentMethodByLocalId(
        sub.paymentMethodId!,
      );
      cloudPaymentMethodId = payment?.cloudId;
    }

    final data = {
      'service_name': sub.serviceName,
      'cost': sub.cost,
      'start_date': sub.startDate.toIso8601String(),
      'billing_cycle': sub.billingCycle.name,
      'status': sub.status,
      'isCancelled': sub.isCancelled,
      'category_id': cloudCategoryId,
      'payment_method_id': cloudPaymentMethodId,
      'user_id': sub.userId,
    };

    debugPrint(data.toString());

    final cloudId = await _supabase.insertSubscription(data);

    final localId = await db.insert('subscriptions', {
      ...sub.toMap(),
      'cloud_id': cloudId,
    });

    await _historyRepo.insertHistory(
      SubscriptionHistory(
        subscriptionId: localId,
        action: "CREATED",
        actionDate: DateTime.now(),
      ),
    );

    return localId;
  }

  // OBTENER TODAS (GLOBAL LOCAL)

  Future<List<Subscription>> getSubscriptions() async {
    final db = await dbHelper.database;

    final result = await db.query('subscriptions');

    return result.map((map) => Subscription.fromMap(map)).toList();
  }

  // 🔥 OBTENER POR USUARIO (CORRECTO)

  Future<List<Subscription>> getSubscriptionsByUser(String userId) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'subscriptions',

      where: 'user_id = ?',

      whereArgs: [userId],
    );

    return result.map((map) => Subscription.fromMap(map)).toList();
  }

  // FULL GENERAL

  Future<List<SubscriptionFull>> getSubscriptionsFull() async {
    final db = await dbHelper.database;

    final subs = await db.query('subscriptions');

    final categories = await db.query('categories');

    final payments = await db.query('payment_methods');

    return subs.map((s) {
      final sub = Subscription.fromMap(s);

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

  // FULL POR USUARIO (CORREGIDO)

  Future<List<SubscriptionFull>> getSubscriptionsFullByUser(
    String userId,
  ) async {
    final db = await dbHelper.database;

    final subs = await db.query(
      'subscriptions',

      where: 'user_id = ?',

      whereArgs: [userId],
    );

    final categories = await db.query('categories');

    final payments = await db.query('payment_methods');

    return subs.map((s) {
      final sub = Subscription.fromMap(s);

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

    final subscription = await getSubscriptionByLocalId(id);

    await db.update(
      'subscriptions',
      {'isCancelled': 1, 'status': 'Cancelled'},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (subscription?.cloudId != null) {
      await _supabase.cancelSubscription(subscription!.cloudId!);
    }

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

    final subscription = await getSubscriptionByLocalId(id);

    await db.update(
      'subscriptions',
      {'isCancelled': 0, 'status': 'Active'},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (subscription?.cloudId != null) {
      await _supabase.restoreSubscription(subscription!.cloudId!);
    }

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

    int? cloudCategoryId;
    int? cloudPaymentMethodId;

    if (sub.categoryId != null) {
      final category = await _categoryRepo.getCategoryByLocalId(
        sub.categoryId!,
      );
      cloudCategoryId = category?.cloudId;
    }

    if (sub.paymentMethodId != null) {
      final payment = await _paymentRepo.getPaymentMethodByLocalId(
        sub.paymentMethodId!,
      );
      cloudPaymentMethodId = payment?.cloudId;
    }

    await db.update(
      'subscriptions',
      sub.toMap(),
      where: 'id = ?',
      whereArgs: [sub.id],
    );

    if (sub.cloudId != null) {
      await _supabase.updateSubscription(
        id: sub.cloudId!,
        data: {
          'service_name': sub.serviceName,
          'cost': sub.cost,
          'start_date': sub.startDate.toIso8601String(),
          'billing_cycle': sub.billingCycle.name,
          'status': sub.status,
          'isCancelled': sub.isCancelled,
          'category_id': cloudCategoryId,
          'payment_method_id': cloudPaymentMethodId,
        },
      );
    }

    debugPrint("========== UPDATE ==========");
    debugPrint("Local ID: ${sub.id}");
    debugPrint("Cloud ID: ${sub.cloudId}");
    debugPrint("Category Local: ${sub.categoryId}");
    debugPrint("Payment Local: ${sub.paymentMethodId}");
    debugPrint("Cloud Category: $cloudCategoryId");
    debugPrint("Cloud Payment: $cloudPaymentMethodId");
  }

  // ==========================
  // BUSCAR POR CLOUD ID
  // ==========================

  Future<Subscription?> getSubscriptionByCloudId(int cloudId) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'subscriptions',
      where: 'cloud_id = ?',
      whereArgs: [cloudId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Subscription.fromMap(result.first);
  }

  // ==========================
  // INSERTAR SOLO SQLITE
  // ==========================

  Future<void> insertLocal(Subscription subscription) async {
    final db = await dbHelper.database;

    await db.insert('subscriptions', subscription.toMap());
  }

  // ==========================
  // UPDATE SOLO SQLITE
  // ==========================

  Future<void> updateLocal(Subscription subscription) async {
    final db = await dbHelper.database;

    await db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }
  // ==========================
  // BUSCAR POR ID LOCAL
  // ==========================

  Future<Subscription?> getSubscriptionByLocalId(int id) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Subscription.fromMap(result.first);
  }

  Future<List<Subscription>> getPendingByUser(String userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'subscriptions',
      where: 'user_id = ? AND cloud_id IS NULL',
      whereArgs: [userId],
    );
    return result.map((e) => Subscription.fromMap(e)).toList();
  }

  Future<void> setCloudId(int localId, int cloudId) async {
    final db = await dbHelper.database;
    await db.update(
      'subscriptions',
      {'cloud_id': cloudId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}
