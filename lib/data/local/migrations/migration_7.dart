import 'package:sqflite/sqflite.dart';

class Migration7 {
  static Future<void> run(Database db) async {
    await db.execute('''
      CREATE TABLE users(

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL,

        email TEXT NOT NULL UNIQUE,

        password TEXT NOT NULL

      )
    ''');

    await db.execute('''

      ALTER TABLE subscriptions

      ADD COLUMN user_id INTEGER

    ''');

    await db.execute('''

      ALTER TABLE payment_history

      ADD COLUMN user_id INTEGER

    ''');
  }
}
