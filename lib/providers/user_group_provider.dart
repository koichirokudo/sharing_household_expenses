import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/user_group_state.dart';
import 'package:url_launcher/url_launcher.dart';

import '../repositories/user_group_repository.dart';

final userGroupProvider =
    StateNotifierProvider<UserGroupNotifier, UserGroupState>(
  (ref) => UserGroupNotifier(UserGroupRepository()),
);

class UserGroupNotifier extends StateNotifier<UserGroupState> {
  final UserGroupRepository repository;

  UserGroupNotifier(this.repository)
      : super(
          UserGroupState(
            isLoading: false,
            inviteCode: null,
            group: null,
          ),
        );

  Future<void> generateInviteCode() async {
    try {
      final response = await repository.generateInviteCode();
      if (response.data['success'] == true) {
        state = state.copyWith(inviteCode: response.data['inviteCode']);
      }
    } catch (e) {
      throw Exception(
          'Failed to generate invite code: ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<void> fetchGroup(String groupId) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.fetchGroup(groupId);
      state = state.copyWith(group: response);
    } catch (e) {
      throw Exception(
          'Failed to fetch group: ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.updateGroup(groupId, data);

      state = state.copyWith(group: response);
    } catch (e) {
      throw Exception(
          'Failed to update group:  ${e.runtimeType} - ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> makeGroup() async {
    try {
      final response = await repository.makeGroup();
      return response;
    } catch (e) {
      throw Exception(
          'Failed to make group: ${e.runtimeType} - ${e.toString()}');
    }
  }

  Future<bool> joinGroup(String inviteCode) async {
    try {
      final response = await repository.joinGroup(inviteCode);
      return response;
    } catch (e) {
      throw Exception(
          'Failed to join group: ${e.runtimeType} - ${e.toString()}');
    }
  }

  // LINE 用の Deep Link 生成
  String generateLineShareUrl(String code, String link) {
    final message = 'シェア家計簿のグループ招待です。招待コードを使ってグループに参加してください。\n'
        '招待コード: $code\nこちらのリンクから参加: $link';
    return 'https://line.me/R/share?text=${Uri.encodeComponent(message)}';
  }

  // Deep Link を開く
  Future<void> openDeepLink(String url) async {
    // URLをUri型に変換
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // 外部アプリでURLを開く
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
