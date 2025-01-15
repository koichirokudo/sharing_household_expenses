import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
            prevMonthTransactions: [],
            prevYearTransactions: [],
            sharedTransactions: [],
            privateTransactions: [],
            sharedTotalAmounts: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            privateTotalAmounts: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            months: [],
          ),
        );

  Future<void> fetchMonthlyTransactions(
      String groupId, DateTime date, String profileId) async {
    state = state.copyWith(isLoading: true);
    try {
      final transactions = await repository.fetchMonthlyByGroup(groupId, date);
      state = state.copyWith(transactions: transactions);
      groupByVisibility(profileId);
      calculateTotalAmounts();
      generateMonths();
    } catch (e) {
      throw Exception('Failed to fetch monthly transactions: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchPrevMonthlyTransactions(
      String groupId, DateTime date) async {
    state = state.copyWith(isLoading: true);
    try {
      final transactions = await repository.fetchMonthlyByGroup(groupId, date);
      state = state.copyWith(prevMonthTransactions: transactions);
    } catch (e) {
      throw Exception('Failed to fetch monthly transactions: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchMonthlyTransactionsBySettlement(String settlementId) async {
    state = state.copyWith(isLoading: true);
    try {
      final transactions =
          await repository.fetchMonthlyBySettlement(settlementId);
      state = state.copyWith(transactions: transactions);
    } catch (e) {
      throw Exception('Failed to fetch monthly transactions: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.insert(transaction);
      final updateTransactions = [...state.transactions, response];
      state = state.copyWith(transactions: updateTransactions);
      calculateTotalAmounts();
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Transaction> updateTransaction(transaction) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.update(transaction);
      if (response == null) {
        throw Exception('トランザクションの更新に失敗しました');
      }
      final updateTransactions = [...state.transactions, response];
      state = state.copyWith(transactions: updateTransactions);
      calculateTotalAmounts();
      return response;
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> upsertTransaction(transaction) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.upsert(transaction);
      state = state.copyWith(transactions: response);
      calculateTotalAmounts();
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    state = state.copyWith(isLoading: true);
    try {
      final id = transaction.id;
      if (id == null) {
        throw Exception('transaction id is null');
      }
      await repository.delete(id);
      final updatedTransactions =
          state.transactions.where((t) => t.id != transaction.id).toList();
      state = state.copyWith(transactions: updatedTransactions);
      calculateTotalAmounts();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteTransactionsByProfile(Profile profile) async {
    state = state.copyWith(isLoading: true);
    try {
      await repository.deleteByProfile(profile.id);
      final updatedTransactions =
          state.transactions.where((t) => t.profileId != profile.id).toList();
      state = state.copyWith(transactions: updatedTransactions);
      calculateTotalAmounts();
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void groupByVisibility(profileId) {
    final transactions = state.transactions;
    final sharedData = transactions.where((transaction) {
      if (transaction.share == true) {
        return true;
      }
      return false;
    }).toList();
    state = state.copyWith(sharedTransactions: sharedData);

    final privateData = transactions.where((transaction) {
      if (transaction.share == false && transaction.profileId == profileId) {
        return true;
      }
      return false;
    }).toList();
    state = state.copyWith(privateTransactions: privateData);
  }

  // １ヶ月分のグループと個人の収支の合計額を計算
  void calculateTotalAmounts() {
    final sharedTotalAmounts = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };
    final privateTotalAmounts = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };

    for (var transaction in state.sharedTransactions) {
      sharedTotalAmounts[transaction.type] =
          (sharedTotalAmounts[transaction.type] ?? 0) + transaction.amount;
    }

    for (var transaction in state.privateTransactions) {
      privateTotalAmounts[transaction.type] =
          (privateTotalAmounts[transaction.type] ?? 0) + transaction.amount;
    }

    state = state.copyWith(
      sharedTotalAmounts: sharedTotalAmounts,
      privateTotalAmounts: privateTotalAmounts,
    );
  }

  // 現在の月から過去１年分(現在の月を含めた13ヶ月分)の月を取得する
  void generateMonths() {
    final currentMonth = DateTime.now();
    List<String> months = List.generate(13, (index) {
      final month = DateTime(currentMonth.year, currentMonth.month - index, 1);
      return DateFormat('yyyy/MM').format(month);
    });
    state = state.copyWith(months: months.reversed.toList());
  }
}
