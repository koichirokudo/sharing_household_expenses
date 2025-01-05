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
}
