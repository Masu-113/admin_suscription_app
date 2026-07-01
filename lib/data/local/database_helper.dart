import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'migrations/migration_5.dart';
import 'migrations/migration_6.dart';
import 'migrations/migration_7.dart';
import 'migrations/migration_8.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await openDatabase(
      join(await getDatabasesPath(), 'subscriptions.db'),

      version: 8,

      onCreate: (db, version) async {
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

            user_id INTEGER

          )
        ''');

        await db.execute('''
          CREATE TABLE users(

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            name TEXT NOT NULL,

            email TEXT NOT NULL UNIQUE,

            password TEXT NOT NULL

          )
        ''');

        await db.execute('''
          CREATE TABLE categories(

          id INTEGER PRIMARY KEY AUTOINCREMENT,

          name TEXT NOT NULL,

          user_id INTEGER

          )
        ''');

        await db.execute('''
          CREATE TABLE payment_methods(

          id INTEGER PRIMARY KEY AUTOINCREMENT,

          type TEXT NOT NULL,

          details TEXT,

          user_id INTEGER

          )
        ''');

        await db.execute('''
          CREATE TABLE payment_history(

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            payment_date TEXT NOT NULL,

            amount REAL NOT NULL,

            subscription_id INTEGER NOT NULL,

            covered_until TEXT NOT NULL,

            user_id INTEGER

          )
        ''');

        await db.execute('''
          CREATE TABLE subscription_history(

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            subscription_id INTEGER NOT NULL,

            action TEXT NOT NULL,

            action_date TEXT NOT NULL

          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await Migration5.run(db);
        }

        if (oldVersion < 6) {
          await Migration6.run(db);
        }

        if (oldVersion < 7) {
          await Migration7.run(db);
        }

        if (oldVersion < 8) {
          await Migration8.run(db);
        }
      },
    );

    return _database!;
  }
}
