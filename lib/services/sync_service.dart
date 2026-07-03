import '../data/repositories/category_repository.dart';
import '../data/repositories/supabase_repository.dart';
import '../models/category.dart';
import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final SupabaseRepository _cloud = SupabaseRepository();
  final CategoryRepository _categories = CategoryRepository();
  final PaymentMethodRepository _paymentMethods = PaymentMethodRepository();

  Future<void> syncAll(String userId) async {
    await syncCategories(userId);
    await syncPaymentMethods(userId);

    // Próximamente
    // await syncPaymentMethods(userId);
    // await syncSubscriptions(userId);
    // await syncPaymentHistory(userId);
    // await syncSubscriptionHistory(userId);
  }

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
}
