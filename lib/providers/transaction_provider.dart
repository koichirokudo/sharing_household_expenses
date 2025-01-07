import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/providers/transaction_state.dart';

import '../models/profile.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
  (ref) => TransactionNotifier(TransactionRepository()),
);

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository repository;

  TransactionNotifier(this.repository)
      : super(
          TransactionState(
            isLoading: false,
            transactions: [],
            sharedTotalAmounts: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            privateTotalAmounts: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
          ),
        );

  Future<void> fetchMonthlyTransactions(String groupId, DateTime month) async {
    try {
      final transactions = await repository.fetchMonthly(groupId, month);
      state = state.copyWith(transactions: transactions);
      calculateTotals();
    } catch (e) {
      throw Exception('Failed to fetch monthly transactions: $e');
    }
  }

  Future<void> insertTransaction(Transaction transaction) async {
    try {
      await repository.insert(transaction);
      final updateTransactions = [...state.transactions, transaction];
      state = state.copyWith(transactions: updateTransactions);
      calculateTotals();
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await repository.update(transaction);
      final updatedTransactions = state.transactions.map((t) {
        return t.id == transaction.id ? transaction : t;
      }).toList();
      state = state.copyWith(transactions: updatedTransactions);
      calculateTotals();
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      final id = transaction.id;
      if (id == null) {
        throw Exception('transaction id is null');
      }
      await repository.delete(id);
      final updatedTransactions =
          state.transactions.where((t) => t.id != transaction.id).toList();
      state = state.copyWith(transactions: updatedTransactions);
      calculateTotals();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<void> deleteTransactionsByProfile(Profile profile) async {
    try {
      await repository.deleteByProfile(profile.id);
      final updatedTransactions =
          state.transactions.where((t) => t.profileId != profile.id).toList();
      state = state.copyWith(transactions: updatedTransactions);
      calculateTotals();
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // 合計金額を計算
  void calculateTotals() {
    final sharedTotalAmounts = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };
    final privateTotalAmounts = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };

    for (var transaction in state.transactions) {
      final targetMap =
          transaction.share ? sharedTotalAmounts : privateTotalAmounts;
      targetMap[transaction.type] =
          (targetMap[transaction.type] ?? 0) + transaction.amount;
    }

    state = state.copyWith(
      sharedTotalAmounts: sharedTotalAmounts,
      privateTotalAmounts: privateTotalAmounts,
    );
  }
}
