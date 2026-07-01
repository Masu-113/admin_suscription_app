import 'package:flutter/material.dart';

import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool isLoading = false;

  String? errorMessage;

  bool get isLoggedIn {
    return _repo.currentSession != null;
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;

      errorMessage = null;

      notifyListeners();

      await _repo.login(email: email, password: password);

      return true;
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

      // Usuario creado pero esperando confirmación por correo

      if (response.user != null && response.session == null) {
        errorMessage =
            "Cuenta creada. Revisa tu correo para confirmar la cuenta.";

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
    await _repo.logout();

    notifyListeners();
  }
}
