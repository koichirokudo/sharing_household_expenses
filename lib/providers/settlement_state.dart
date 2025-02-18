import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/settlement.dart';
import '../models/settlement_item.dart';

part 'settlement_state.freezed.dart';

@freezed
class SettlementState with _$SettlementState {
  const factory SettlementState({
    required bool isLoading,
    required bool isSettlementComplete,
    required Settlement? settlement,
    required List<Settlement> settlements,
    required List<SettlementItem> settlementItems,
    required List<Settlement> sharedSettlements,
    required List<Settlement> privateSettlements,
    required Map<String, Map<String, dynamic>> sharedIncomeAmounts,
    required Map<String, Map<String, dynamic>> sharedExpenseAmounts,
    required Map<String, Map<String, dynamic>> privateIncomeAmounts,
    required Map<String, Map<String, dynamic>> privateExpenseAmounts,
    required Map<String, dynamic> payer,
    required Map<String, dynamic> payee,
    required int incomeTotal,
    required int expenseTotal,
    required int amountPerPerson,
    required List<String> years,
    String? errorMessage,
  }) = _SettlementState;
}
