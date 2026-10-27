import '../data/repositories/category_repository.dart';
import '../data/repositories/supabase_repository.dart';
import '../models/category.dart';
import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';
import '../data/repositories/subscription_repository.dart';
import '../models/subscription.dart';
import '../data/repositories/payment_history_repository.dart';
import '../models/payment_history.dart';
import '../models/billing_cycle.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();
  final SupabaseRepository _cloud = SupabaseRepository();
  final CategoryRepository _categories = CategoryRepository();
  final PaymentMethodRepository _paymentMethods = PaymentMethodRepository();
  final SubscriptionRepository _subscriptions = SubscriptionRepository();
  final PaymentHistoryRepository _paymentHistory = PaymentHistoryRepository();

  Future<void> pushPending(String userId) async {
    // 1. Categorías
    for (final c in await _categories.getPendingByUser(userId)) {
      try {
        final cloudId = await _cloud.insertCategory(
          name: c.name,
          userId: userId,
        );
        await _categories.setCloudId(c.id!, cloudId);
      } catch (e) {
        debugPrint("No se pudo subir categoría ${c.id}: $e");
      }
    }

    // 2. Métodos de pago
    for (final m in await _paymentMethods.getPendingByUser(userId)) {
      try {
        final cloudId = await _cloud.insertPaymentMethod(
          type: m.type,
          details: m.details,
          userId: userId,
        );
        await _paymentMethods.setCloudId(m.id!, cloudId);
      } catch (e) {
        debugPrint("No se pudo subir método ${m.id}: $e");
      }
    }

    // 3. Suscripciones
    for (final s in await _subscriptions.getPendingByUser(userId)) {
      try {
        int? cloudCategoryId;
        int? cloudMethodId;

        if (s.categoryId != null) {
          cloudCategoryId = (await _categories.getCategoryByLocalId(
            s.categoryId!,
          ))?.cloudId;
        }
        if (s.paymentMethodId != null) {
          cloudMethodId = (await _paymentMethods.getPaymentMethodByLocalId(
            s.paymentMethodId!,
          ))?.cloudId;
        }

        final cloudId = await _cloud.insertSubscription({
          'service_name': s.serviceName,
          'cost': s.cost,
          'start_date': s.startDate.toIso8601String(),
          'billing_cycle': s.billingCycle.name,
          'status': s.status,
          'isCancelled': s.isCancelled,
          'category_id': cloudCategoryId,
          'payment_method_id': cloudMethodId,
          'user_id': userId,
        });
        await _subscriptions.setCloudId(s.id!, cloudId);
      } catch (e) {
        debugPrint("No se pudo subir suscripción ${s.id}: $e");
      }
    }

    // 4. Pagos
    for (final p in await _paymentHistory.getPendingByUser(userId)) {
      try {
        final sub = await _subscriptions.getSubscriptionByLocalId(
          p.subscriptionId,
        );
        if (sub?.cloudId == null) continue; // se subirá en la próxima pasada

        final cloudId = await _cloud.insertPaymentHistory(
          subscriptionId: sub!.cloudId!,
          amount: p.amount,
          paymentDate: p.paymentDate,
          coveredUntil: p.coveredUntil,
        );
        await _paymentHistory.updateCloudId(p.id!, cloudId);
      } catch (e) {
        debugPrint("No se pudo subir pago ${p.id}: $e");
      }
    }
  }
  // MASTER SYNC

  Future<void> syncAll(String userId) async {
    await pushPending(userId); // <- NUEVA: primero subir lo pendiente
    await syncCategories(userId);
    await syncPaymentMethods(userId);
    // IMPORTANTE: subscriptions primero
    await syncSubscriptions(userId);
    // luego dependientes
    await syncPaymentHistory(userId);
  }

  // CATEGORIES

  Future<void> syncCategories(String userId) async {
    final cloudCategories = await _cloud.getCategories(userId);
    for (final item in cloudCategories) {
      final cloudId = item['id'] as int;
      final local = await _categories.getCategoryByCloudId(cloudId);
      final category = Category(
        id: local?.id,
        cloudId: cloudId,
        name: item['name'] as String,
        userId: item['user_id'] as String,
      );
      if (local == null) {
        await _categories.insertLocal(category);
      } else {
        await _categories.updateLocal(category);
      }
    }
  }

  // PAYMENT METHODS

  Future<void> syncPaymentMethods(String userId) async {
    final cloudMethods = await _cloud.getPaymentMethods(userId);
    for (final item in cloudMethods) {
      final cloudId = item['id'] as int;
      final local = await _paymentMethods.getPaymentMethodByCloudId(cloudId);
      final method = PaymentMethod(
        id: local?.id,
        cloudId: cloudId,
        type: item['type'] as String,
        details: item['details'] as String?,
        userId: item['user_id'] as String,
      );
      if (local == null) {
        await _paymentMethods.insertLocal(method);
      } else {
        await _paymentMethods.updateLocal(method);
      }
    }
  }

  // SUBSCRIPTIONS

  Future<void> syncSubscriptions(String userId) async {
    final cloudSubscriptions = await _cloud.getSubscriptions(userId);
    for (final item in cloudSubscriptions) {
      final cloudId = item['id'] as int;
      final local = await _subscriptions.getSubscriptionByCloudId(cloudId);
      int? localCategoryId;
      int? localPaymentMethodId;
      if (item['category_id'] != null) {
        final category = await _categories.getCategoryByCloudId(
          item['category_id'] as int,
        );
        localCategoryId = category?.id;
      }
      if (item['payment_method_id'] != null) {
        final payment = await _paymentMethods.getPaymentMethodByCloudId(
          item['payment_method_id'] as int,
        );
        localPaymentMethodId = payment?.id;
      }
      final subscription = Subscription(
        id: local?.id,
        cloudId: cloudId,
        serviceName: item['service_name'] as String,
        cost: (item['cost'] as num).toDouble(),
        startDate: DateTime.parse(item['start_date'] as String),
        billingCycle: BillingCycle.values.firstWhere(
          (e) => e.name == item['billing_cycle'],
        ),
        status: item['status'] as String,
        isCancelled: item['isCancelled'] as int,
        categoryId: localCategoryId,
        paymentMethodId: localPaymentMethodId,
        userId: item['user_id'] as String,
      );
      if (local == null) {
        await _subscriptions.insertLocal(subscription);
      } else {
        await _subscriptions.updateLocal(subscription);
      }
    }
  }

  // PAYMENT HISTORY

  Future<void> syncPaymentHistory(String userId) async {
    final cloudPayments = await _cloud.getPaymentsByUser(userId);
    for (final item in cloudPayments) {
      final cloudId = item['id'] as int;
      final subscription = await _subscriptions.getSubscriptionByCloudId(
        item['subscription_id'] as int,
      );
      if (subscription == null) continue;
      final local = await _paymentHistory.getPaymentHistoryByCloudId(cloudId);
      final payment = PaymentHistory(
        id: local?.id,
        idCloud: cloudId,
        paymentDate: DateTime.parse(item['payment_date'] as String),
        amount: (item['amount'] as num).toDouble(),
        subscriptionId: subscription.id!,
        coveredUntil: DateTime.parse(item['covered_until'] as String),
      );
      if (local == null) {
        final localId = await _paymentHistory.insertLocal(payment);
        await _paymentHistory.updateCloudId(localId, cloudId);
      } else {
        await _paymentHistory.updateLocal(payment);
      }
    }
  }
}
