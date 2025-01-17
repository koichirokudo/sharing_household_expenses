import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/user_group.dart';

part 'user_group_state.freezed.dart';

@freezed
class UserGroupState with _$UserGroupState {
  factory UserGroupState({
    required bool isLoading,
    required String? inviteCode,
    required UserGroup? group,
  }) = _UserGroupState;
}
