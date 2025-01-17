import 'package:sharing_household_expenses/models/user_group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';

class UserGroupRepository {
  // 招待コード生成
  Future<FunctionResponse> generateInviteCode() async {
    return await supabase.functions.invoke('generate-group-invite-code');
  }

  // グループ取得
  Future<UserGroup> fetchGroup(String groupId) async {
    final response =
        await supabase.from('user_groups').select().eq('id', groupId).single();

    if (response.isEmpty) {
      throw Exception('グループが取得できません');
    }

    return UserGroup.fromMap(response);
  }

  // グループ変更
  Future<UserGroup> updateGroup(
      String groupId, Map<String, dynamic> data) async {
    final response = await supabase
        .from('user_groups')
        .update(data)
        .eq('id', groupId)
        .select()
        .single();
    return UserGroup.fromMap(response);
  }

  Future<bool> makeGroup() async {
    final response = await supabase.functions.invoke('make-user-group');
    if (response.data['success'] == true) {
      return true;
    } else {
      return false;
    }
  }

  // グループに参加
  Future<bool> joinGroup(String inviteCode) async {
    final response = await supabase.functions.invoke('join-group', body: {
      'invite_code': inviteCode,
    });
    if (response.data['success'] == true) {
      return true;
    } else {
      return false;
    }
  }
}
