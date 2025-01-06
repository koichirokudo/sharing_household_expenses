import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    return await supabase.from('profiles').select().eq('id', userId).single();
  }

  // プロフィール更新
  Future<Map<String, dynamic>> updateProfile(
      String userId, Map<String, dynamic> data) async {
    return await supabase
        .from('profiles')
        .update(data)
        .eq('id', userId)
        .select()
        .single();
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
