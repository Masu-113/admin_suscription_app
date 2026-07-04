import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/supabase_repository.dart';
import '../data/repositories/user_repository.dart';
import '../models/user.dart';

//Sincronización de datos entre SQLite y Supabase
import '../services/sync_service.dart';

class SessionManager extends ChangeNotifier {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  final UserRepository _userRepository = UserRepository();
  final SupabaseRepository _supabaseRepository = SupabaseRepository();

  UserModel? _currentUser;

  bool _isInitializing = false;

  UserModel? get currentUser => _currentUser;

  String? get userId => _currentUser?.id;

  bool get isLoggedIn => _currentUser != null;

  bool get isInitializing => _isInitializing;

  Future<void> initialize() async {
    if (_isInitializing) return;

    _isInitializing = true;
    notifyListeners();

    try {
      debugPrint("========== SESSION MANAGER ==========");

      final supabaseUser = Supabase.instance.client.auth.currentUser;

      if (supabaseUser == null) {
        debugPrint("No existe sesión en Supabase.");

        _currentUser = null;

        return;
      }

      debugPrint("Supabase User: ${supabaseUser.email}");
      debugPrint("UUID: ${supabaseUser.id}");

      final userId = supabaseUser.id;

      final name =
          supabaseUser.userMetadata?['name'] ??
          supabaseUser.email?.split('@').first ??
          "Usuario";

      final email = supabaseUser.email!;

      // Sincronizar usuario con Supabase
      await _supabaseRepository.upsertUser(
        id: userId,
        name: name,
        email: email,
      );

      // Sincronizar usuario con SQLite
      UserModel? localUser = await _userRepository.getUserById(userId);

      if (localUser == null) {
        debugPrint("Usuario NO existe en SQLite. Creándolo...");

        await _userRepository.saveUser(
          UserModel(id: userId, name: name, email: email),
        );

        localUser = await _userRepository.getUserById(userId);
      } else {
        debugPrint("Usuario encontrado en SQLite.");
      }

      _currentUser = localUser;
      // Sincronizar datos entre SQLite y Supabase
      await SyncService.instance.syncAll(userId);
      if (kDebugMode) {
        debugPrint(
          "Sincronización completa para el usuario: ${_currentUser?.email}",
        );
      }
      debugPrint("Usuario actual: ${_currentUser?.email}");
      debugPrint("UUID actual: ${_currentUser?.id}");
    } catch (e, s) {
      debugPrint("Error inicializando sesión:");
      debugPrint(e.toString());
      debugPrint(s.toString());

      _currentUser = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();

    _currentUser = null;

    debugPrint("Sesión cerrada.");

    notifyListeners();
  }
}
