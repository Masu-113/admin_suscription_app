import '../local/database_helper.dart';
import '../../models/category.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Category>> getCategories() async {
    final db = await _dbHelper.database;

    final result = await db.query('categories');

    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<void> insertCategory(Category category) async {
    final db = await _dbHelper.database;

    await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    final db = await _dbHelper.database;

    await db.update(
      'categories',

      category.toMap(),

      where: 'id = ?',

      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await _dbHelper.database;

    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
