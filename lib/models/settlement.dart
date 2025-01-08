import '../constants/settlement_status.dart';
import '../constants/settlement_visibility.dart';

class Settlement {
  final int id;
  final String groupId;
  final SettlementVisibility visibility;
  final String settlementDate;
  final double incomeTotalAmount;
  final double expenseTotalAmount;
  final double amountPerPerson;
  final SettlementStatus? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Settlement({
    required this.id,
    required this.groupId,
    required this.visibility,
    required this.settlementDate,
    required this.incomeTotalAmount,
    required this.expenseTotalAmount,
    required this.amountPerPerson,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Settlement.fromMap(Map<String, dynamic> map) {
    return Settlement(
      id: map['id'],
      groupId: map['group_id'],
      visibility: SettlementVisibility.values
          .firstWhere((e) => e.name == map['visibility']),
      settlementDate: map['settlement_date'],
      incomeTotalAmount: map['income_total_amount'],
      expenseTotalAmount: map['expense_total_amount'],
      amountPerPerson: map['amount_per_person'],
      status: map['status'] != null
          ? SettlementStatus.values.firstWhere((e) => e.name == map['status'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'visibility': visibility.name,
      'settlement_date': settlementDate,
      'income_total_amount': incomeTotalAmount,
      'expense_total_amount': expenseTotalAmount,
      'amount_per_person': amountPerPerson,
      'status': status?.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
