import '../constants/cancel_reason.dart';
import '../constants/invite_status.dart';

class Profile {
  final String id;
  final String? groupId;
  final String username;
  final String? avatarUrl;
  final String? avatarFilename;
  final InviteStatus inviteStatus;
  final DateTime? invitedAt;
  final bool cancel;
  final CancelReason? cancelReason;
  final DateTime? canceledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.groupId,
    required this.username,
    this.avatarUrl,
    this.avatarFilename,
    required this.inviteStatus,
    this.invitedAt,
    this.cancel = false,
    this.cancelReason,
    this.canceledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      groupId: map['group_id'],
      username: map['username'],
      avatarUrl: map['avatar_url'],
      avatarFilename: map['avatar_filename'],
      inviteStatus:
          InviteStatus.values.firstWhere((e) => e.name == map['invite_status']),
      invitedAt:
          map['invited_at'] != null ? DateTime.parse(map['invited_at']) : null,
      cancel: map['cancel'] ?? false,
      cancelReason: map['cancel_reason'] != null
          ? CancelReason.values
              .firstWhere((e) => e.name == map['cancel_reason'])
          : null,
      canceledAt: map['canceled_at'] != null
          ? DateTime.parse(map['canceled_at'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'username': username,
      'avatar_url': avatarUrl,
      'avatar_filename': avatarFilename,
      'invite_status': inviteStatus.name,
      'invited_at': invitedAt?.toIso8601String(),
      'cancel': cancel,
      'cancel_reason': cancelReason?.name,
      'canceled_at': canceledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
