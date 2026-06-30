import 'package:sqflite/sqflite.dart';

class Migration5 {
  static Future<void> run(Database db) async {
    await db.execute('''
      ALTER TABLE subscriptions
      ADD COLUMN isCancelled INTEGER NOT NULL DEFAULT 0
    ''');
  }
}
