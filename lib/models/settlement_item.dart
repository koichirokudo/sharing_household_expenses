import 'package:sharing_household_expenses/models/profile.dart';

import '../constants/role.dart';

class SettlementItem {
  final int id;
  final int settlementId;
  final String profileId;
  final Role role;
  final double amount;
  final double percentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Profile profile;

  SettlementItem({
    required this.id,
    required this.settlementId,
    required this.profileId,
    required this.role,
    required this.amount,
    required this.percentage,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
  });

  factory SettlementItem.fromMap(Map<String, dynamic> map) {
    return SettlementItem(
      id: map['id'],
      settlementId: map['settlement_id'],
      profileId: map['profile_id'],
      role: Role.values.firstWhere((e) => e.name == map['role']),
      amount: map['amount'],
      percentage: map['percentage'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      profile: Profile.fromMap(map['profiles']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'settlement_id': settlementId,
      'profile_id': profileId,
      'role': role.name,
      'amount': amount,
      'percentage': percentage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profiles': profile.toMap(),
    };
  }
}
