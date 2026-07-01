import '../local/database_helper.dart';
import '../../models/user.dart';

class UserRepository {
  final dbHelper = DatabaseHelper();

  // CREAR USUARIO

  Future<int> insertUser(UserModel user) async {
    final db = await dbHelper.database;

    final id = await db.insert('users', user.toMap());

    return id;
  }

  // OBTENER TODOS LOS USUARIOS

  Future<List<UserModel>> getUsers() async {
    final db = await dbHelper.database;

    final result = await db.query('users');

    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  // OBTENER USUARIO POR ID

  Future<UserModel?> getUserById(int id) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',

      where: 'id = ?',

      whereArgs: [id],

      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.first);
  }

  // BUSCAR POR EMAIL

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'users',

      where: 'email = ?',

      whereArgs: [email],

      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.first);
  }

  // ACTUALIZAR USUARIO

  Future<void> updateUser(UserModel user) async {
    final db = await dbHelper.database;

    await db.update(
      'users',

      user.toMap(),

      where: 'id = ?',

      whereArgs: [user.id],
    );
  }

  // ELIMINAR USUARIO

  Future<void> deleteUser(int id) async {
    final db = await dbHelper.database;

    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
