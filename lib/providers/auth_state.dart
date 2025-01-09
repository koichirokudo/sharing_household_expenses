import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sharing_household_expenses/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required bool isLoading,
    required bool isAuthenticated,
    required Session? session,
    required User? user,
    required Profile? profile,
    required List<Profile>? profiles,
    String? errorMessage,
  }) = _AuthState;
}
