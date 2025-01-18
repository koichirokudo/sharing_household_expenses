import 'package:freezed_annotation/freezed_annotation.dart';

import '../constants/transaction_type.dart';
import '../models/transaction.dart';

part 'transaction_state.freezed.dart';

@freezed
class TransactionState with _$TransactionState {
  const factory TransactionState({
    required bool isLoading,
    required List<Transaction> transactions,
    required List<Transaction> sharedTransactions,
    required List<Transaction> privateTransactions,
    required List<Transaction> prevMonthTransactions,
    required List<Transaction> sharedPrevMonthTransactions,
    required List<Transaction> privatePrevMonthTransactions,
    required List<Transaction> prevYearTransactions,
    required List<Transaction> sharedPrevYearTransactions,
    required List<Transaction> privatePrevYearTransactions,
    required Map<TransactionType, double> sharedCurrentTotals,
    required Map<TransactionType, double> privateCurrentTotals,
    required Map<TransactionType, double> sharedPrevMonthTotals,
    required Map<TransactionType, double> privatePrevMonthTotals,
    required Map<TransactionType, double> sharedPrevYearTotals,
    required Map<TransactionType, double> privatePrevYearTotals,
    required Map<String, double> sharedIncomeSections,
    required Map<String, double> sharedExpenseSections,
    required Map<String, double> privateIncomeSections,
    required Map<String, double> privateExpenseSections,
    required List<String> months,
  }) = _TransactionState;
}
