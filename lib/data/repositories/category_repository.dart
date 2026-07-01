import '../local/database_helper.dart';
import '../../models/category.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // TODAS LAS CATEGORIAS
  // (uso futuro/admin)

  Future<List<Category>> getCategories() async {
    final db = await _dbHelper.database;

    final result = await db.query('categories');

    return result.map((e) => Category.fromMap(e)).toList();
  }

  // CATEGORIAS POR USUARIO

  Future<List<Category>> getCategoriesByUser(int userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'categories',

      where: 'user_id = ?',

      whereArgs: [userId],
    );

    return result.map((e) => Category.fromMap(e)).toList();
  }

  // INSERTAR

  Future<void> insertCategory(Category category) async {
    final db = await _dbHelper.database;

    await db.insert('categories', category.toMap());
  }

  // UPDATE

  Future<void> updateCategory(Category category) async {
    final db = await _dbHelper.database;

    await db.update(
      'categories',

      category.toMap(),

      where: 'id = ?',

      whereArgs: [category.id],
    );
  }

  // DELETE

  Future<void> deleteCategory(int id) async {
    final db = await _dbHelper.database;

    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
