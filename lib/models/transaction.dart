import '../constants/transaction_type.dart';
import '../constants/visibility.dart';

class Transaction {
  final int id;
  final String profileId;
  final String groupId;
  final Visibility visibility;
  final int? settlementId;
  final int categoryId;
  final String name;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final bool share;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.profileId,
    required this.groupId,
    required this.visibility,
    this.settlementId,
    required this.categoryId,
    required this.name,
    required this.date,
    required this.type,
    required this.amount,
    this.share = false,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      profileId: map['profile_id'],
      groupId: map['group_id'],
      visibility:
          Visibility.values.firstWhere((e) => e.name == map['visibility']),
      settlementId: map['settlement_id'],
      categoryId: map['category_id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      amount: map['amount'],
      share: map['share'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'group_id': groupId,
      'visibility': visibility.name,
      'settlement_id': settlementId,
      'category_id': categoryId,
      'name': name,
      'date': date.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'share': share,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
