import 'package:sharing_household_expenses/models/profile.dart';

import '../constants/transaction_type.dart';
import 'category.dart';

class Transaction {
  final int? id;
  final String profileId;
  final String groupId;
  final int? settlementId;
  final int categoryId;
  final String? name;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final bool share;
  final DateTime createdAt;
  final DateTime updatedAt;
  late final Category? category;
  late final Profile? profile;

  Transaction({
    this.id,
    required this.profileId,
    required this.groupId,
    this.settlementId,
    required this.categoryId,
    this.name,
    required this.date,
    required this.type,
    required this.amount,
    this.share = false,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.profile,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      profileId: map['profile_id'],
      groupId: map['group_id'],
      settlementId: map['settlement_id'],
      categoryId: map['sub_category_id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'] as double,
      share: map['share'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      category: map['categories'] != null
          ? Category.fromMap(map['categories'])
          : null,
      profile:
          map['profiles'] != null ? Profile.fromMap(map['profiles']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'group_id': groupId,
      'settlement_id': settlementId,
      'category_id': categoryId,
      'name': name,
      'date': date.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'share': share,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'categories': category?.toMap(),
      'profiles': profile?.toMap(),
    };
  }

  Map<String, dynamic> toMapForInsert() {
    return {
      'profile_id': profileId,
      'group_id': groupId,
      'settlement_id': settlementId,
      'category_id': categoryId,
      'name': name,
      'date': date.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'share': share,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'id': id,
      'profile_id': profileId,
      'group_id': groupId,
      'settlement_id': settlementId,
      'category_id': categoryId,
      'name': name,
      'date': date.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'share': share,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
