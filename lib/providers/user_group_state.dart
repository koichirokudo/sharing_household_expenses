import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_group_state.freezed.dart';

@freezed
class UserGroupState with _$UserGroupState {
  factory UserGroupState({
    required String? inviteCode,
    required Map<String, dynamic>? group,
  }) = _UserGroupState;
}
