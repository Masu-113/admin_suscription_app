import 'package:flutter/material.dart';

import '../core/session_manager.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool isLoading = false;

  String? errorMessage;

  bool get isLoggedIn => _repo.currentSession != null;

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _repo.login(email: email, password: password);

      // Sincroniza el usuario autenticado con SQLite
      await SessionManager.instance.initialize();

      debugPrint("========== LOGIN ==========");
      debugPrint(
        "Usuario actual: ${SessionManager.instance.currentUser?.email}",
      );
      debugPrint("ID: ${SessionManager.instance.userId}");

      return SessionManager.instance.isLoggedIn;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _repo.register(
        name: name,
        email: email,
        password: password,
      );

      if (response.user != null && response.session == null) {
        errorMessage =
            "Cuenta creada correctamente. Revisa tu correo electrónico y confirma tu cuenta antes de iniciar sesión.";

        return false;
      }

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SessionManager.instance.logout();

    notifyListeners();
  }
}
