import '../local/database_helper.dart';
import '../../models/subscription_history.dart';

class SubscriptionHistoryRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  // INSERTAR EVENTO EN HISTORIAL

  Future<void> insertHistory(SubscriptionHistory history) async {
    final db = await dbHelper.database;

    await db.insert('subscription_history', history.toMap());
  }

  // OBTENER HISTORIAL DE UNA SUSCRIPCIÓN

  Future<List<SubscriptionHistory>> getHistoryBySubscription(
    int subscriptionId,
  ) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'subscription_history',

      where: 'subscription_id = ?',

      whereArgs: [subscriptionId],

      orderBy: 'action_date DESC',
    );

    return result.map((map) {
      return SubscriptionHistory.fromMap(map);
    }).toList();
  }

  // ELIMINAR HISTORIAL (opcional)

  Future<void> deleteHistoryBySubscription(int subscriptionId) async {
    final db = await dbHelper.database;

    await db.delete(
      'subscription_history',

      where: 'subscription_id = ?',

      whereArgs: [subscriptionId],
    );
  }
}
