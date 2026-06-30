import 'package:sqflite/sqflite.dart';

class Migration6 {
  static Future<void> run(Database db) async {
    await db.execute('''
      CREATE TABLE subscription_history(

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        subscription_id INTEGER NOT NULL,

        action TEXT NOT NULL,

        action_date TEXT NOT NULL

      )
    ''');
  }
}
