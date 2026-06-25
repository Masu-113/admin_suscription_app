import '../local/database_helper.dart';
import '../../models/category.dart';

class CategoryRepository {
  final dbHelper = DatabaseHelper();

  // INSERTAR
  Future<void> insertCategory(Category category) async {
    final db = await dbHelper.database;

    await db.insert('categories', category.toMap());
  }

  // OBTENER TODAS
  Future<List<Category>> getCategories() async {
    final db = await dbHelper.database;

    final result = await db.query('categories');

    return result.map((map) {
      return Category(id: map['id'] as int?, name: map['name'] as String);
    }).toList();
  }
}
