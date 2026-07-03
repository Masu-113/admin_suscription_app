import '../data/repositories/category_repository.dart';
import '../data/repositories/supabase_repository.dart';
import '../models/category.dart';

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final SupabaseRepository _cloud = SupabaseRepository();
  final CategoryRepository _categories = CategoryRepository();

  Future<void> syncAll(String userId) async {
    await syncCategories(userId);

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
}
