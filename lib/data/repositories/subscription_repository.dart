import '../local/database_helper.dart';
import '../../models/subscription.dart';

class SubscriptionRepository {
  final dbHelper = DatabaseHelper();

  // INSERTAR SUSCRIPCION
  Future<void> insertSubscription(Subscription sub) async {
    final db = await dbHelper.database;

    await db.insert('subscriptions', sub.toMap());
  }

  // OBTENER TODAS LAS SUSCRIPCIONES
  Future<List<Subscription>> getSubscriptions() async {
    final db = await dbHelper.database;

    final result = await db.query('subscriptions');

    return result.map((map) {
      return Subscription(
        id: map['id'] as int?,
        serviceName: (map['service_name'] ?? '') as String,
        cost: (map['cost'] as num).toDouble(),
        renewalDate: DateTime.parse(map['renewal_date'] as String),
        status: (map['status'] ?? 'Active') as String,
      );
    }).toList();
  }

  // ELIMINAR SUSCRIPCION
  Future<void> deleteSubscription(int id) async {
    final db = await dbHelper.database;

    await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // ACTUALIZAR SUSCRIPCION
  Future<void> updateSubscription(Subscription sub) async {
    final db = await dbHelper.database;

    await db.update(
      'subscriptions',

      sub.toMap(),

      where: 'id = ?',

      whereArgs: [sub.id],
    );
  }
}
