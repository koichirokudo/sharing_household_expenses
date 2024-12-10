import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  late final SupabaseClient supabase;
  ProfileService(this.supabase);

  Future<PostgrestMap> fetchProfile() async {
    final userId = supabase.auth.currentSession!.user.id;
    final response =
        await supabase.from('profiles').select().eq('id', userId).single();
    return response;
  }
}
