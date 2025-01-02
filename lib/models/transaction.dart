import 'package:sharing_household_expenses/models/profile.dart';
import 'package:sharing_household_expenses/models/sub_category.dart';

import '../constants/transaction_type.dart';

class Transaction {
  final int id;
  final String profileId;
  final String groupId;
  final int? settlementId;
  final int subCategoryId;
  final String name;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final bool share;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubCategory? subCategory;
  final Profile? profile;

  Transaction({
    required this.id,
    required this.profileId,
    required this.groupId,
    this.settlementId,
    required this.subCategoryId,
    required this.name,
    required this.date,
    required this.type,
    required this.amount,
    this.share = false,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.subCategory,
    this.profile,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      profileId: map['profile_id'],
      groupId: map['group_id'],
      settlementId: map['settlement_id'],
      subCategoryId: map['sub_category_id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      amount: map['amount'],
      share: map['share'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      subCategory: map['sub_categories'] != null
          ? SubCategory.fromMap(map['sub_categories'])
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
      'sub_category_id': subCategoryId,
      'name': name,
      'date': date.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'share': share,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'subCategories': subCategory?.toMap(),
      'profiles': profile?.toMap(),
    };
  }
}
