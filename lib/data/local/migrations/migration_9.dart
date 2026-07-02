import 'package:sqflite/sqflite.dart';

class Migration9 {
  static Future<void> run(Database db) async {
    // Crear nueva tabla users

    await db.execute('''
      CREATE TABLE users_new(

        id TEXT PRIMARY KEY,

        name TEXT NOT NULL,

        email TEXT NOT NULL UNIQUE

      )
    ''');

    // Migrar usuarios existentes
    //
    // Como los usuarios anteriores tenían INTEGER ids
    // no podemos conservarlos como UUID reales.
    // Los dejamos fuera porque ahora la identidad viene de Supabase.

    await db.execute('''
      DROP TABLE users
    ''');

    await db.execute('''
      ALTER TABLE users_new
      RENAME TO users
    ''');

    // Recrear subscriptions

    await db.execute('''
      CREATE TABLE subscriptions_new(

        id INTEGER PRIMARY KEY AUTOINCREMENT,

        service_name TEXT NOT NULL,

        cost REAL NOT NULL,

        start_date TEXT NOT NULL,

        billing_cycle TEXT NOT NULL,

        status TEXT NOT NULL,

        category_id INTEGER,

        payment_method_id INTEGER,

        isCancelled INTEGER NOT NULL DEFAULT 0,

        user_id TEXT

      )
    ''');

    await db.execute('''
      INSERT INTO subscriptions_new
      SELECT
        id,
        service_name,
        cost,
        start_date,
        billing_cycle,
        status,
        category_id,
        payment_method_id,
        isCancelled,
        NULL
      FROM subscriptions
    ''');

    await db.execute('''
      DROP TABLE subscriptions
    ''');

    await db.execute('''
      ALTER TABLE subscriptions_new
      RENAME TO subscriptions
    ''');

    // Categories

    await db.execute('''
      ALTER TABLE categories
      ADD COLUMN temp_user_id TEXT
    ''');

    await db.execute('''
      UPDATE categories
      SET temp_user_id = NULL
    ''');

    // Payment methods

    await db.execute('''
      ALTER TABLE payment_methods
      ADD COLUMN temp_user_id TEXT
    ''');

    await db.execute('''
      UPDATE payment_methods
      SET temp_user_id = NULL
    ''');
  }
}
