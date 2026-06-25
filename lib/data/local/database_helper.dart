import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await openDatabase(
      join(await getDatabasesPath(), 'subscriptions.db'),

      version: 1,

      onCreate: (db, version) {
        db.execute('''

CREATE TABLE subscriptions(

id TEXT PRIMARY KEY,

serviceName TEXT,

price REAL,

renewalDate TEXT,

status TEXT

)

''');
      },
    );

    return _database!;
  }
}
