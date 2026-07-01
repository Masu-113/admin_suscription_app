import 'package:flutter/material.dart';

import '../models/user.dart';
import '../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  List<UserModel> users = [];

  UserModel? currentUser;

  bool isLoading = false;

  // CARGAR USUARIOS

  Future<void> loadUsers() async {
    try {
      isLoading = true;

      notifyListeners();

      users = await _repo.getUsers();
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // CREAR USUARIO

  Future<int> addUser(UserModel user) async {
    final id = await _repo.insertUser(user);

    await loadUsers();

    return id;
  }

  // BUSCAR USUARIO POR EMAIL

  Future<UserModel?> login(String email, String password) async {
    final user = await _repo.getUserByEmail(email);

    if (user == null) {
      return null;
    }

    if (user.password != password) {
      return null;
    }

    currentUser = user;

    notifyListeners();

    return user;
  }

  // CERRAR SESION

  void logout() {
    currentUser = null;

    notifyListeners();
  }

  // ACTUALIZAR

  Future<void> updateUser(UserModel user) async {
    await _repo.updateUser(user);

    await loadUsers();
  }

  // ELIMINAR

  Future<void> deleteUser(int id) async {
    await _repo.deleteUser(id);

    await loadUsers();
  }
}
