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

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();
  final SupabaseRepository _cloud = SupabaseRepository();
  final CategoryRepository _categories = CategoryRepository();
  final PaymentMethodRepository _paymentMethods = PaymentMethodRepository();
  final SubscriptionRepository _subscriptions = SubscriptionRepository();
  final PaymentHistoryRepository _paymentHistory = PaymentHistoryRepository();

  // MASTER SYNC

  Future<void> syncAll(String userId) async {
    await syncCategories(userId);
    await syncPaymentMethods(userId);
    // IMPORTANTE: subscriptions primero
    await syncSubscriptions(userId);
    // luego dependientes
    await syncPaymentHistory(userId);
    // futuro:
    // await syncSubscriptionHistory(userId);
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
