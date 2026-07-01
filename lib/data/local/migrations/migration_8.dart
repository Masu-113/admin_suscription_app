import 'package:sqflite/sqflite.dart';

class Migration8 {
  static Future<void> run(Database db) async {
    await db.execute('''

      ALTER TABLE categories

      ADD COLUMN user_id INTEGER

    ''');
  }
}
