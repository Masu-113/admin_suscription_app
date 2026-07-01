import 'package:sqflite/sqflite.dart';

class Migration8 {
  static Future<void> run(Database db) async {
    // Agregar usuario a categorías

    await db.execute('''
      ALTER TABLE categories
      ADD COLUMN user_id INTEGER
    ''');

    // Agregar usuario a métodos de pago

    await db.execute('''
      ALTER TABLE payment_methods
      ADD COLUMN user_id INTEGER
    ''');
  }
}
