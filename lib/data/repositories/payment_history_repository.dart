import '../local/database_helper.dart';
import '../../models/payment_history.dart';

class PaymentHistoryRepository {
  final dbHelper = DatabaseHelper();

  // INSERTAR PAGO

  Future<int> insertPayment(PaymentHistory payment) async {
    final db = await dbHelper.database;

    final id = await db.insert('payment_history', payment.toMap());

    return id;
  }

  // OBTENER HISTORIAL COMPLETO
  // futuro uso admin

  Future<List<PaymentHistory>> getPayments() async {
    final db = await dbHelper.database;

    final result = await db.query(
      'payment_history',
      orderBy: 'payment_date DESC',
    );

    return result.map((map) => PaymentHistory.fromMap(map)).toList();
  }

  // OBTENER PAGOS POR USUARIO

  Future<List<PaymentHistory>> getPaymentsByUser(int userId) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT payment_history.*
      FROM payment_history

      INNER JOIN subscriptions
      ON payment_history.subscription_id = subscriptions.id

      WHERE subscriptions.user_id = ?

      ORDER BY payment_history.payment_date DESC
      ''',
      [userId],
    );

    return result.map((map) => PaymentHistory.fromMap(map)).toList();
  }

  // OBTENER PAGOS DE UNA SUSCRIPCIÓN

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

  // ACTUALIZAR PAGO

  Future<void> updatePayment(PaymentHistory payment) async {
    final db = await dbHelper.database;

    await db.update(
      'payment_history',

      payment.toMap(),

      where: 'id = ?',

      whereArgs: [payment.id],
    );
  }

  // ELIMINAR PAGO

  Future<void> deletePayment(int id) async {
    final db = await dbHelper.database;

    await db.delete('payment_history', where: 'id = ?', whereArgs: [id]);
  }
}
