import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../utils/constants.dart';

class AuthRepository {
  // サインイン
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  // サインアウト
  Future<void> signOut() async {
    return await supabase.auth.signOut();
  }

  // プロフィール取得
  Future<Profile> fetchProfile(String userId) async {
    final response =
        await supabase.from('profiles').select().eq('id', userId).single();

    if (response.isEmpty) {
      throw Exception('プロフィールが取得できません');
    }

    return Profile.fromMap(response);
  }

  // グループ全員のプロフィール情報を取得
  Future<List<Profile>> fetchProfiles(String groupId) async {
    final response =
        await supabase.from('profiles').select().eq('group_id', groupId);

    if (response.isEmpty) {
      throw Exception('プロフィールが取得できません');
    }

    return (response as List<dynamic>)
        .map((profile) => Profile.fromMap(profile))
        .toList();
  }

  // プロフィール更新
  Future<Profile> updateProfile(
      String userId, Map<String, dynamic> data) async {
    final response = await supabase
        .from('profiles')
        .update(data)
        .eq('id', userId)
        .select()
        .single();
    return Profile.fromMap(response);
  }

  // ユーザー登録
  Future<AuthResponse> signUpUser(
      {required String username,
      required String email,
      required String password}) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );
  }

  // ユーザー情報更新
  Future<UserResponse?> updateUser({String? email, String? password}) async {
    if (email != null) {
      return await supabase.auth.updateUser(
        UserAttributes(email: email),
        emailRedirectTo: '${dotenv.get('SCHEME')}://change-email/',
      );
    } else if (password != null) {
      return await supabase.auth.updateUser(
        UserAttributes(password: password),
      );
    }
    return null;
  }

  // ユーザーの削除
  Future<bool> deleteUser() async {
    final response = await supabase.functions.invoke('delete-user');
    if (response.data['success'] == true) {
      return true;
    } else {
      return false;
    }
  }

  // 指定したメールアドレスへリセットメールを送信
  Future<void> sendResetPasswordEmail({required String email}) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: '${dotenv.get('SCHEME')}://reset-password/',
    );
  }
}
