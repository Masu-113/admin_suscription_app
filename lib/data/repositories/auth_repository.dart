import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // REGISTRO

  Future<AuthResponse> register({
    required String name,

    required String email,

    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,

      password: password,

      data: {'name': name},
    );
  }

  // LOGIN

  Future<AuthResponse> login({
    required String email,

    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,

      password: password,
    );
  }

  // LOGOUT

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // SESION ACTUAL

  Session? get currentSession {
    return _client.auth.currentSession;
  }

  // USUARIO ACTUAL

  User? get currentUser {
    return _client.auth.currentUser;
  }
}
