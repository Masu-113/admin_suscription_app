import '../local/database_helper.dart';
import '../../models/payment_history.dart';

class PaymentHistoryRepository {
  final dbHelper = DatabaseHelper();

  // 🟢 INSERTAR PAGO
  Future<void> insertPayment(PaymentHistory payment) async {
    final db = await dbHelper.database;

    await db.insert('payment_history', payment.toMap());
  }

  // 🟢 OBTENER HISTORIAL COMPLETO
  Future<List<PaymentHistory>> getPayments() async {
    final db = await dbHelper.database;

    final result = await db.query(
      'payment_history',
      orderBy: 'payment_date DESC',
    );

    return result.map((map) {
      return PaymentHistory.fromMap(map);
    }).toList();
  }

  // 🟡 OBTENER PAGOS DE UNA SUSCRIPCIÓN
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

    return result.map((map) {
      return PaymentHistory.fromMap(map);
    }).toList();
  }

  // 🔴 ELIMINAR PAGO
  Future<void> deletePayment(int id) async {
    final db = await dbHelper.database;

    await db.delete('payment_history', where: 'id = ?', whereArgs: [id]);
  }
}
