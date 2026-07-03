import '../local/database_helper.dart';
import '../repositories/supabase_repository.dart';
import '../../models/payment_method.dart';

class PaymentMethodRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SupabaseRepository _supabase = SupabaseRepository();

  // ==========================
  // TODAS
  // ==========================

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final db = await _dbHelper.database;

    final result = await db.query('payment_methods');

    return result.map((e) => PaymentMethod.fromMap(e)).toList();
  }

  // ==========================
  // POR USUARIO
  // ==========================

  Future<List<PaymentMethod>> getPaymentMethodsByUser(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'payment_methods',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((e) => PaymentMethod.fromMap(e)).toList();
  }

  // ==========================
  // INSERTAR
  // ==========================

  Future<void> insertPaymentMethod(PaymentMethod method) async {
    final db = await _dbHelper.database;

    final localId = await db.insert('payment_methods', method.toMap());

    final cloudId = await _supabase.insertPaymentMethod(
      type: method.type,
      details: method.details,
      userId: method.userId!,
    );

    await db.update(
      'payment_methods',
      {'cloud_id': cloudId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ==========================
  // UPDATE
  // ==========================

  Future<void> updatePaymentMethod({
    required int cloudId,
    required String type,
    required String? details,
  }) async {
    await _supabase.updatePaymentMethod(
      id: cloudId,
      type: type,
      details: details,
    );
  }

  // ==========================
  // DELETE
  // ==========================

  Future<void> deletePaymentMethod(PaymentMethod method) async {
    final db = await _dbHelper.database;

    await db.delete('payment_methods', where: 'id = ?', whereArgs: [method.id]);

    if (method.cloudId != null) {
      await _supabase.deletePaymentMethod(method.cloudId!);
    }
  }

  // ==========================
  // BUSCAR POR CLOUD ID
  // ==========================

  Future<PaymentMethod?> getPaymentMethodByCloudId(int cloudId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'payment_methods',
      where: 'cloud_id = ?',
      whereArgs: [cloudId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return PaymentMethod.fromMap(result.first);
  }

  // ==========================
  // INSERTAR SOLO SQLITE
  // ==========================

  Future<void> insertLocal(PaymentMethod method) async {
    final db = await _dbHelper.database;

    await db.insert('payment_methods', method.toMap());
  }

  // ==========================
  // UPDATE SOLO SQLITE
  // ==========================

  Future<void> updateLocal(PaymentMethod method) async {
    final db = await _dbHelper.database;

    await db.update(
      'payment_methods',
      method.toMap(),
      where: 'id = ?',
      whereArgs: [method.id],
    );
  }
}
