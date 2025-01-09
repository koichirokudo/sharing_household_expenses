import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_state.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../repositories/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(AuthRepository()));

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository)
      : super(
          AuthState(
            isLoading: false,
            isAuthenticated: supabase.auth.currentUser != null,
            user: supabase.auth.currentUser,
            session: supabase.auth.currentSession,
            profile: null,
            profiles: [],
          ),
        );

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.signIn(email, password);
      if (response.session != null) {
        state = state.copyWith(session: response.session, user: response.user);
      } else {
        throw Exception('セッションを取得できません');
      }
    } catch (e) {
      throw Exception('Failed to sign in: ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await repository.signOut();
      state = state.copyWith(
          isAuthenticated: false, session: null, profile: null, user: null);
    } catch (e) {
      throw Exception('Failed to sign out: ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = state.user?.id;
      if (userId == null) {
        throw Exception('ユーザーIDが取得できません');
      }

      final response = await repository.fetchProfile(userId);

      state = state.copyWith(profile: response);
    } catch (e) {
      throw Exception(
          'Failed to fetch profile: ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchProfiles() async {
    state = state.copyWith(isLoading: true);
    try {
      final groupId = state.profile?.groupId;
      if (groupId == null) {
        throw Exception('グループIDが取得できません');
      }

      final response = await repository.fetchProfiles(groupId);

      state = state.copyWith(profiles: response);
    } catch (e) {
      throw Exception(
          'Failed to fetch profiles: ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = state.user?.id;
      if (userId == null) {
        throw Exception('ユーザーIDが取得できません');
      }

      final response = await repository.updateProfile(userId, data);

      state = state.copyWith(profile: response);
    } catch (e) {
      throw Exception(
          'Failed to update profile:  ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateUser({String? email, String? password}) async {
    state = state.copyWith(isLoading: true);
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
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> deleteUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.deleteUser();
      return response;
    } catch (e) {
      throw Exception(
          'Failed to delete user:  ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendResetPasswordEmail({required String email}) async {
    state = state.copyWith(isLoading: true);
    try {
      await repository.sendResetPasswordEmail(email: email);
    } catch (e) {
      throw Exception(
          'Failed to send reset password email:  ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
