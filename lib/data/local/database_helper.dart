import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper _instance = DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'subscriptions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // ==========================
        // USERS
        // ==========================

        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE
          )
        ''');

        // ==========================
        // CATEGORIES
        // ==========================

        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            user_id TEXT NOT NULL
          )
        ''');

        // ==========================
        // PAYMENT METHODS
        // ==========================

        await db.execute('''
          CREATE TABLE payment_methods(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            details TEXT,
            user_id TEXT NOT NULL
          )
        ''');

        // ==========================
        // SUBSCRIPTIONS
        // ==========================

        await db.execute('''
          CREATE TABLE subscriptions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            service_name TEXT NOT NULL,
            cost REAL NOT NULL,
            start_date TEXT NOT NULL,
            billing_cycle TEXT NOT NULL,
            status TEXT NOT NULL,
            category_id INTEGER,
            payment_method_id INTEGER,
            isCancelled INTEGER NOT NULL DEFAULT 0,
            user_id TEXT NOT NULL
          )
        ''');

        // ==========================
        // PAYMENT HISTORY
        // ==========================

        await db.execute('''
          CREATE TABLE payment_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            payment_date TEXT NOT NULL,
            amount REAL NOT NULL,
            subscription_id INTEGER NOT NULL,
            covered_until TEXT NOT NULL
          )
        ''');

        // ==========================
        // SUBSCRIPTION HISTORY
        // ==========================

        await db.execute('''
          CREATE TABLE subscription_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subscription_id INTEGER NOT NULL,
            action TEXT NOT NULL,
            action_date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'subscriptions.db');

    await deleteDatabase(path);

    _database = null;
  }
}
