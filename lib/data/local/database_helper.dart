import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'subscriptions.db'),

      version: 2,

      onCreate: (db, version) async {
        // SUBSCRIPTIONS (ACTUALIZADA)
        await db.execute('''
          CREATE TABLE subscriptions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            service_name TEXT,
            cost REAL,
            renewal_date TEXT,
            status TEXT,
            category_id INTEGER,
            payment_method_id INTEGER
          )
        ''');

        // CATEGORIES
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        // PAYMENT METHODS
        await db.execute('''
          CREATE TABLE payment_methods(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            details TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute("DROP TABLE IF EXISTS subscriptions");
        await db.execute("DROP TABLE IF EXISTS categories");
        await db.execute("DROP TABLE IF EXISTS payment_methods");

        // RECREAR TODO

        await db.execute('''
          CREATE TABLE subscriptions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            service_name TEXT,
            cost REAL,
            renewal_date TEXT,
            status TEXT,
            category_id INTEGER,
            payment_method_id INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE payment_methods(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            details TEXT
          )
        ''');
      },
    );

    return _database!;
  }
}
