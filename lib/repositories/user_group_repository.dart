import 'package:functions_client/src/types.dart';

import '../utils/constants.dart';

class UserGroupRepository {
  // 招待コード生成
  Future<FunctionResponse> generateInviteCode() async {
    return await supabase.functions.invoke('generate-group-invite-code');
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
