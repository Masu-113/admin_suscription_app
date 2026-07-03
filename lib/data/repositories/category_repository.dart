import '../local/database_helper.dart';
import '../repositories/supabase_repository.dart';
import '../../models/category.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SupabaseRepository _supabase = SupabaseRepository();

  // ==========================
  // TODAS (ADMIN / DEBUG)
  // ==========================

  Future<List<Category>> getCategories() async {
    final db = await _dbHelper.database;

    final result = await db.query('categories');

    return result.map((e) => Category.fromMap(e)).toList();
  }

  // ==========================
  // POR USUARIO
  // ==========================

  Future<List<Category>> getCategoriesByUser(String userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((e) => Category.fromMap(e)).toList();
  }

  // ==========================
  // INSERTAR
  // ==========================

  Future<void> insertCategory(Category category) async {
    final db = await _dbHelper.database;

    // Guardar primero en SQLite
    final localId = await db.insert('categories', category.toMap());

    // Guardar también en Supabase
    final cloudId = await _supabase.insertCategory(
      name: category.name,
      userId: category.userId!,
    );

    // Guardar el id de Supabase en SQLite
    await db.update(
      'categories',
      {'cloud_id': cloudId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ==========================
  // UPDATE
  // ==========================

  Future<void> updateCategory({
    required int cloudId,
    required String name,
  }) async {
    await _supabase.updateCategory(id: cloudId, name: name);
  }
  // ==========================
  // DELETE
  // ==========================

  Future<void> deleteCategory(Category category) async {
    final db = await _dbHelper.database;

    await db.delete('categories', where: 'id = ?', whereArgs: [category.id]);

    if (category.cloudId != null) {
      await _supabase.deleteCategory(category.cloudId!);
    }
  }

  // ==========================
  // BUSCAR POR ID LOCAL
  // ==========================

  Future<Category?> getCategoryByLocalId(int localId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [localId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Category.fromMap(result.first);
  }

  // ==========================
  // BUSCAR POR CLOUD ID
  // ==========================

  Future<Category?> getCategoryByCloudId(int cloudId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'categories',
      where: 'cloud_id = ?',
      whereArgs: [cloudId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Category.fromMap(result.first);
  }

  // ==========================
  // INSERTAR SOLO EN SQLITE
  // (USADO POR LA SINCRONIZACIÓN)
  // ==========================

  Future<void> insertLocal(Category category) async {
    final db = await _dbHelper.database;

    await db.insert('categories', category.toMap());
  }

  // ==========================
  // UPDATE SOLO SQLITE
  // ==========================

  Future<void> updateLocal(Category category) async {
    final db = await _dbHelper.database;

    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }
}
