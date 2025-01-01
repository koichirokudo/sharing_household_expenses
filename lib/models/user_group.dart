// Models
class UserGroup {
  final String id;
  final String groupName;
  final String slug;
  final String inviteCode;
  final DateTime? inviteLimit;
  final int startDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserGroup({
    required this.id,
    required this.groupName,
    required this.slug,
    required this.inviteCode,
    this.inviteLimit,
    required this.startDay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserGroup.fromMap(Map<String, dynamic> map) {
    return UserGroup(
      id: map['id'],
      groupName: map['group_name'],
      slug: map['slug'],
      inviteCode: map['invite_code'],
      inviteLimit: map['invite_limit'] != null
          ? DateTime.parse(map['invite_limit'])
          : null,
      startDay: map['start_day'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_name': groupName,
      'slug': slug,
      'invite_code': inviteCode,
      'invite_limit': inviteLimit?.toIso8601String(),
      'start_day': startDay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
