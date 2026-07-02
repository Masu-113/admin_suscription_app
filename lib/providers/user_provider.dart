import 'package:flutter/material.dart';

import '../models/user.dart';
import '../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  List<UserModel> users = [];

  UserModel? currentUser;

  bool isLoading = false;

  // CARGAR USUARIOS LOCALES

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

  // GUARDAR USUARIO LOCAL (CACHE)

  Future<void> saveUser(UserModel user) async {
    await _repo.saveUser(user);

    currentUser = user;

    await loadUsers();

    notifyListeners();
  }

  // BUSCAR USUARIO POR EMAIL

  Future<UserModel?> getUserByEmail(String email) async {
    return await _repo.getUserByEmail(email);
  }

  // BUSCAR USUARIO POR ID

  Future<UserModel?> getUserById(String id) async {
    return await _repo.getUserById(id);
  }

  // ACTUALIZAR USUARIO

  Future<void> updateUser(UserModel user) async {
    await _repo.updateUser(user);

    currentUser = user;

    await loadUsers();

    notifyListeners();
  }

  // ELIMINAR USUARIO

  Future<void> deleteUser(String id) async {
    await _repo.deleteUser(id);

    if (currentUser?.id == id) {
      currentUser = null;
    }

    await loadUsers();

    notifyListeners();
  }

  // ESTABLECER USUARIO ACTUAL

  void setCurrentUser(UserModel? user) {
    currentUser = user;

    notifyListeners();
  }

  // CERRAR USUARIO LOCAL

  void clearUser() {
    currentUser = null;

    notifyListeners();
  }
}
