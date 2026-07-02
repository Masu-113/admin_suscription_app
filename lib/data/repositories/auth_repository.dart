import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // REGISTRO

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  // LOGIN

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  // LOGOUT

  Future<void> logout() {
    return _client.auth.signOut();
  }

  // SESIÓN ACTUAL

  Session? get currentSession => _client.auth.currentSession;

  // USUARIO ACTUAL

  User? get currentUser => _client.auth.currentUser;
}
