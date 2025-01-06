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
          user: supabase.auth.currentUser,
          session: supabase.auth.currentSession,
          profile: null,
        ));

  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await repository.signIn(email, password);
      if (response.session != null) {
        state = state.copyWith(session: response.session);
      } else {
        throw Exception('セッションを取得できませんでした');
      }
    } catch (e) {
      throw Exception('Failed to sign in: ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await repository.signOut();
      state =
          state.copyWith(isAuthenticated: false, session: null, profile: null);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<void> fetchProfile() async {
    try {
      final userId = state.session?.user.id;
      if (userId == null) {
        throw Exception('ユーザーIDが取得できませんでした');
      }

      final response = await repository.fetchProfile(userId);

      if (response.isEmpty) {
        throw Exception('プロフィールを取得できませんでした');
      }

      state = state.copyWith(profile: response);
    } catch (e) {
      throw Exception(
          'Failed to fetch profile: ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = state.session?.user.id;
      if (userId == null) {
        throw Exception('ユーザーIDが取得できませんでした');
      }

      final response = await repository.updateProfile(userId, data);

      state = state.copyWith(profile: response);
    } catch (e) {
      throw Exception(
          'Failed to update profile:  ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<void> updateUser({String? email, String? password}) async {
    try {
      final response =
          await repository.updateUser(email: email, password: password);
      if (response != null) {
        state = state.copyWith(user: response.user);
      } else {
        throw Exception('ユーザー情報の更新に失敗しました');
      }
    } catch (e) {
      throw Exception(
          'Failed to update user:  ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<bool> deleteUser() async {
    try {
      final response = await repository.deleteUser();
      return response;
    } catch (e) {
      throw Exception(
          'Failed to delete user:  ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<void> sendResetPasswordEmail({required String email}) async {
    try {
      await repository.sendResetPasswordEmail(email: email);
    } catch (e) {
      throw Exception(
          'Failed to send reset password email:  ${e.runtimeType} - ${e.toString()}');
    }
  }
}
