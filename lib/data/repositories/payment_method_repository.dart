import '../local/database_helper.dart';
import '../../models/payment_method.dart';

class PaymentMethodRepository {
  final dbHelper = DatabaseHelper();

  // 🟢 INSERTAR
  Future<void> insertPaymentMethod(PaymentMethod method) async {
    final db = await dbHelper.database;

    await db.insert('payment_methods', method.toMap());
  }

  // 🟢 OBTENER TODOS
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final db = await dbHelper.database;

    final result = await db.query('payment_methods');

    return result.map((map) {
      return PaymentMethod(
        id: map['id'] as int?,

        type: map['type'] as String,

        details: map['details'] as String?,
      );
    }).toList();
  }

  // 🟡 ACTUALIZAR
  Future<void> updatePaymentMethod(PaymentMethod method) async {
    final db = await dbHelper.database;

    await db.update(
      'payment_methods',

      method.toMap(),

      where: 'id = ?',

      whereArgs: [method.id],
    );
  }

  // 🔴 ELIMINAR
  Future<void> deletePaymentMethod(int id) async {
    final db = await dbHelper.database;

    await db.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }
}
