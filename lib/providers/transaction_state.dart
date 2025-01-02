import 'package:freezed_annotation/freezed_annotation.dart';

import '../constants/transaction_type.dart';
import '../models/transaction.dart';

part 'transaction_state.freezed.dart';

@freezed
class TransactionState with _$TransactionState {
  const factory TransactionState({
    required bool isLoading,
    required List<Transaction> transactions,
    required Map<TransactionType, double> sharedTotalAmounts,
    required Map<TransactionType, double> privateTotalAmounts,
  }) = _TransactionState;
}
