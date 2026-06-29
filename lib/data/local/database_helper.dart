import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'subscriptions.db'),

      version: 4,

      onCreate: (db, version) async {
        // 🟢 SUBSCRIPTIONS
        await db.execute('''
          CREATE TABLE subscriptions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            service_name TEXT NOT NULL,
            cost REAL NOT NULL,
            start_date TEXT NOT NULL,
            billing_cycle TEXT NOT NULL,
            status TEXT NOT NULL,
            category_id INTEGER,
            payment_method_id INTEGER
          )
        ''');

        // 🟢 CATEGORIES
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        // 🟢 PAYMENT METHODS
        await db.execute('''
          CREATE TABLE payment_methods(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            details TEXT
          )
        ''');

        // 🟢 PAYMENT HISTORY
        await db.execute('''
          CREATE TABLE payment_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            payment_date TEXT NOT NULL,
            amount REAL NOT NULL,
            subscription_id INTEGER NOT NULL,
            covered_until TEXT NOT NULL
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        // versión 3 → 4
        if (oldVersion < 4) {
          await db.execute('''
            ALTER TABLE payment_history
            ADD COLUMN covered_until TEXT
          ''');
        }
      },
    );

    return _database!;
  }
}
