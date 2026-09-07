import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final _supabase = Supabase.instance.client;

  AuthCubit() : super(AuthInitial()) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        // Validate if user is admin
        final isAdmin = await _checkIfAdmin(session.user.id);
        if (isAdmin) {
          emit(Authenticated(session.user));
        } else {
          // If not admin, sign out and show error
          await _supabase.auth.signOut();
          emit(const AuthError('Access Denied. Admin privileges required.'));
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<bool> _checkIfAdmin(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && response['role'] == 'admin') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // The onAuthStateChange listener will handle the role verification and emitting Authenticated state
      } else {
        emit(const AuthError('Login failed. Please try again.'));
        emit(Unauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('An unexpected error occurred.'));
      emit(Unauthenticated());
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _supabase.auth.signOut();
    // Listener will handle emitting Unauthenticated
  }
}
