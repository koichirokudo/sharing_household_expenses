import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_state.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../repositories/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(AuthRepository()));

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository)
      : super(AuthState(
          isAuthenticated: supabase.auth.currentUser != null,
          session: supabase.auth.currentSession,
          profile: null,
        ));

  Future<void> fetchProfile() async {
    try {
      final userId = state.session?.user.id;
      if (userId == null) {
        throw Exception('Unable to obtain user id');
      }

      final response = await repository.fetchProfile(userId);

      if (response.isEmpty) {
        throw Exception('Not found profile');
      }

      state = state.copyWith(profile: response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await repository.signIn(email, password);
      if (response.session != null) {
        state = state.copyWith(session: response.session);
      } else {
        throw Exception('Session data is null');
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await repository.signOut();
      state =
          state.copyWith(isAuthenticated: false, session: null, profile: null);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
