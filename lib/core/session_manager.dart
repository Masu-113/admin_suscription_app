import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/user_repository.dart';
import '../models/user.dart';

class SessionManager extends ChangeNotifier {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  String? get userId => _currentUser?.id;

  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    debugPrint("========== SESSION MANAGER ==========");

    final supabaseUser = Supabase.instance.client.auth.currentUser;

    if (supabaseUser == null) {
      debugPrint("No existe sesión en Supabase.");

      _currentUser = null;

      notifyListeners();

      return;
    }

    debugPrint("Supabase User: ${supabaseUser.email}");
    debugPrint("UUID: ${supabaseUser.id}");

    UserModel? localUser = await _userRepository.getUserById(supabaseUser.id);

    if (localUser == null) {
      debugPrint("Usuario NO existe en SQLite. Creándolo...");

      await _userRepository.saveUser(
        UserModel(
          id: supabaseUser.id,
          name:
              supabaseUser.userMetadata?['name'] ??
              supabaseUser.email?.split('@').first ??
              "Usuario",
          email: supabaseUser.email!,
        ),
      );

      localUser = await _userRepository.getUserById(supabaseUser.id);
    } else {
      debugPrint("Usuario encontrado en SQLite.");
    }

    _currentUser = localUser;

    debugPrint("Usuario actual: ${_currentUser?.email}");
    debugPrint("UUID actual: ${_currentUser?.id}");

    notifyListeners();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();

    _currentUser = null;

    notifyListeners();
  }
}
