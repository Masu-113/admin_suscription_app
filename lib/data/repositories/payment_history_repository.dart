import '../local/database_helper.dart';
import '../../models/payment_history.dart';

import 'supabase_repository.dart';
import 'subscription_repository.dart';

class PaymentHistoryRepository {
  final dbHelper = DatabaseHelper();

  final SupabaseRepository _supabase = SupabaseRepository();
  final SubscriptionRepository _subscriptionRepo = SubscriptionRepository();

  // ==========================
  // INSERTAR (SUPABASE + SQLITE)
  // ==========================

  Future<int> insertPayment(PaymentHistory payment) async {
    final db = await dbHelper.database;

    final subscription = await _subscriptionRepo.getSubscriptionByLocalId(
      payment.subscriptionId,
    );

    final cloudSubscriptionId = subscription?.cloudId;

    if (cloudSubscriptionId == null) {
      throw Exception('La suscripción aún no está sincronizada con Supabase.');
    }

    final cloudId = await _supabase.insertPaymentHistory(
      subscriptionId: cloudSubscriptionId,
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      coveredUntil: payment.coveredUntil,
    );

    final localId = await db.insert('payment_history', {
      'cloud_id': cloudId,
      'payment_date': payment.paymentDate.toIso8601String(),
      'amount': payment.amount,
      'subscription_id': payment.subscriptionId,
      'covered_until': payment.coveredUntil.toIso8601String(),
    });

    return localId;
  }

  // ==========================
  // INSERTAR SOLO SQLITE
  // ==========================

  Future<int> insertLocal(PaymentHistory payment) async {
    final db = await dbHelper.database;

    return await db.insert('payment_history', {
      'cloud_id': payment.idCloud,
      'payment_date': payment.paymentDate.toIso8601String(),
      'amount': payment.amount,
      'subscription_id': payment.subscriptionId,
      'covered_until': payment.coveredUntil.toIso8601String(),
    });
  }

  // ==========================
  // ACTUALIZAR CLOUD ID
  // ==========================

  Future<void> updateCloudId(int localId, int cloudId) async {
    final db = await dbHelper.database;

    await db.update(
      'payment_history',
      {'cloud_id': cloudId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ==========================
  // OBTENER TODOS
  // ==========================

  Future<List<PaymentHistory>> getPayments() async {
    final db = await dbHelper.database;

    final result = await db.query(
      'payment_history',
      orderBy: 'payment_date DESC',
    );

    return result.map((map) => PaymentHistory.fromMap(map)).toList();
  }

  // ==========================
  // OBTENER POR SUSCRIPCIÓN
  // ==========================

  Future<List<PaymentHistory>> getPaymentsBySubscription(
    int subscriptionId,
  ) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'payment_history',
      where: 'subscription_id = ?',
      whereArgs: [subscriptionId],
      orderBy: 'payment_date DESC',
    );

    return result.map((map) => PaymentHistory.fromMap(map)).toList();
  }

  // ==========================
  // ACTUALIZAR SOLO SQLITE
  // ==========================

  Future<void> updateLocal(PaymentHistory payment) async {
    final db = await dbHelper.database;

    await db.update(
      'payment_history',
      {
        'cloud_id': payment.idCloud,
        'payment_date': payment.paymentDate.toIso8601String(),
        'amount': payment.amount,
        'subscription_id': payment.subscriptionId,
        'covered_until': payment.coveredUntil.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  // ==========================
  // ELIMINAR SOLO SQLITE
  // ==========================

  Future<void> deleteLocal(int id) async {
    final db = await dbHelper.database;

    await db.delete('payment_history', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================
  // BUSCAR POR CLOUD ID
  // ==========================

  Future<PaymentHistory?> getPaymentHistoryByCloudId(int cloudId) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'payment_history',
      where: 'cloud_id = ?',
      whereArgs: [cloudId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return PaymentHistory.fromMap(result.first);
  }

  Future<List<PaymentHistory>> getPaymentsByUser(String userId) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
    SELECT ph.*
    FROM payment_history ph
    INNER JOIN subscriptions s ON s.id = ph.subscription_id
    WHERE s.user_id = ?
    ORDER BY ph.payment_date DESC
    ''',
      [userId],
    );

    return result.map((map) => PaymentHistory.fromMap(map)).toList();
  }
}
