import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // =========================
  // USERS
  // =========================

  Future<void> upsertUser({
    required String id,
    required String name,
    required String email,
  }) async {
    await _client.from('users').upsert({
      'id': id,
      'name': name,
      'email': email,
    });
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    return await _client.from('users').select().eq('id', id).maybeSingle();
  }

  // =========================
  // CATEGORIES
  // =========================

  Future<List<Map<String, dynamic>>> getCategories(String userId) async {
    return await _client
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('name');
  }

  Future<int> insertCategory({
    required String name,
    required String userId,
  }) async {
    final response = await _client
        .from('categories')
        .insert({'name': name, 'user_id': userId})
        .select('id')
        .single();

    return response['id'] as int;
  }

  Future<void> updateCategory({required int id, required String name}) async {
    await _client.from('categories').update({'name': name}).eq('id', id);
  }

  Future<void> deleteCategory(int id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  // =========================
  // PAYMENT METHODS
  // =========================

  Future<List<Map<String, dynamic>>> getPaymentMethods(String userId) async {
    return await _client
        .from('payment_methods')
        .select()
        .eq('user_id', userId)
        .order('type');
  }

  Future<int> insertPaymentMethod({
    required String type,
    required String? details,
    required String userId,
  }) async {
    final response = await _client
        .from('payment_methods')
        .insert({'type': type, 'details': details, 'user_id': userId})
        .select('id')
        .single();

    return response['id'] as int;
  }

  Future<void> updatePaymentMethod({
    required int id,
    required String type,
    required String? details,
  }) async {
    await _client
        .from('payment_methods')
        .update({'type': type, 'details': details})
        .eq('id', id);
  }

  Future<void> deletePaymentMethod(int id) async {
    await _client.from('payment_methods').delete().eq('id', id);
  }

  // =========================
  // SUBSCRIPTIONS
  // =========================

  Future<List<Map<String, dynamic>>> getSubscriptions(String userId) async {
    return await _client
        .from('subscriptions')
        .select('''
          *,
          categories(name),
          payment_methods(type)
        ''')
        .eq('user_id', userId);
  }

  Future<int> insertSubscription(Map<String, dynamic> data) async {
    final response = await _client
        .from('subscriptions')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as int;
  }

  Future<void> updateSubscription({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    await _client.from('subscriptions').update(data).eq('id', id);
  }

  Future<void> cancelSubscription(int id) async {
    await _client
        .from('subscriptions')
        .update({'isCancelled': 1, 'status': 'Cancelled'})
        .eq('id', id);
  }

  // =========================
  // PAYMENT HISTORY
  // =========================

  Future<int> insertPaymentHistory({
    required int subscriptionId,
    required double amount,
    required DateTime paymentDate,
    required DateTime coveredUntil,
  }) async {
    final response = await _client
        .from('payment_history')
        .insert({
          'subscription_id': subscriptionId,
          'amount': amount,
          'payment_date': paymentDate.toIso8601String(),
          'covered_until': coveredUntil.toIso8601String(),
        })
        .select('id')
        .single();

    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getPayments(int subscriptionId) async {
    return await _client
        .from('payment_history')
        .select()
        .eq('subscription_id', subscriptionId)
        .order('payment_date', ascending: false);
  }

  // =========================
  // SUBSCRIPTION HISTORY
  // =========================

  Future<int> insertSubscriptionHistory({
    required int subscriptionId,
    required String action,
    required DateTime actionDate,
  }) async {
    final response = await _client
        .from('subscription_history')
        .insert({
          'subscription_id': subscriptionId,
          'action': action,
          'action_date': actionDate.toIso8601String(),
        })
        .select('id')
        .single();

    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getSubscriptionHistory(
    int subscriptionId,
  ) async {
    return await _client
        .from('subscription_history')
        .select()
        .eq('subscription_id', subscriptionId)
        .order('action_date', ascending: false);
  }
}
