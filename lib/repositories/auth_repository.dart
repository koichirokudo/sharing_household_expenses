import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';

class AuthRepository {
  // プロフィールを取得する
  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    return await supabase.from('profiles').select().eq('id', userId).single();
  }

  // サインイン
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  // サインアウト
  Future<void> signOut() async {
    return await supabase.auth.signOut();
  }
}
