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
            sharedCurrentTotals: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            privateCurrentTotals: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            sharedPrevMonthTotals: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            privatePrevMonthTotals: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            sharedPrevYearTotals: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            privatePrevYearTotals: {
              TransactionType.income: 0.0,
              TransactionType.expense: 0.0
            },
            months: [],
          ),
        );

  Future<void> fetchMonthlyTransactions(String groupId, DateTime date) async {
    state = state.copyWith(isLoading: true);
    try {
      final transactions = await repository.fetchMonthlyByGroup(groupId, date);
      state = state.copyWith(transactions: transactions);
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
      throw Exception('Failed to fetch prev monthly transactions: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchPrevYearlyTransactions(
      String groupId, DateTime date) async {
    state = state.copyWith(isLoading: true);
    try {
      final transactions = await repository.fetchMonthlyByGroup(groupId, date);
      state = state.copyWith(prevYearTransactions: transactions);
    } catch (e) {
      throw Exception('Failed to fetch prev monthly transactions: $e');
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
      calculateCurrentTotals();
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
      calculateCurrentTotals();
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
      calculateCurrentTotals();
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
      calculateCurrentTotals();
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
      calculateCurrentTotals();
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 今月のグループと個人の収支の合計額を計算
  void calculateCurrentTotals() {
    final sharedCurrentTotals = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };
    final privateCurrentTotals = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };

    // 今月の共有データ
    for (var transaction in state.transactions) {
      if (transaction.share == true) {
        sharedCurrentTotals[transaction.type] =
            (sharedCurrentTotals[transaction.type] ?? 0) + transaction.amount;
      } else {
        privateCurrentTotals[transaction.type] =
            (privateCurrentTotals[transaction.type] ?? 0) + transaction.amount;
      }
    }

    state = state.copyWith(
      sharedCurrentTotals: sharedCurrentTotals,
      privateCurrentTotals: privateCurrentTotals,
    );
  }

  void calculatePrevMonthTotals() {
    final sharedPrevMonthTotals = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };
    final privatePrevMonthTotals = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };

    // 前月の共有データ
    for (var transaction in state.prevMonthTransactions) {
      if (transaction.share == true) {
        sharedPrevMonthTotals[transaction.type] =
            (sharedPrevMonthTotals[transaction.type] ?? 0) + transaction.amount;
      } else {
        privatePrevMonthTotals[transaction.type] =
            (privatePrevMonthTotals[transaction.type] ?? 0) +
                transaction.amount;
      }
    }
    state = state.copyWith(
      sharedPrevMonthTotals: sharedPrevMonthTotals,
      privatePrevMonthTotals: privatePrevMonthTotals,
    );
  }

  void calculatePrevYearTotals() {
    final sharedPrevYearTotals = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };
    final privatePrevYearTotals = {
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
    };

    // 前年の共有データ
    for (var transaction in state.prevYearTransactions) {
      if (transaction.share == true) {
        sharedPrevYearTotals[transaction.type] =
            (sharedPrevYearTotals[transaction.type] ?? 0) + transaction.amount;
      } else {
        privatePrevYearTotals[transaction.type] =
            (privatePrevYearTotals[transaction.type] ?? 0) + transaction.amount;
      }
    }
    state = state.copyWith(
      sharedPrevYearTotals: sharedPrevYearTotals,
      privatePrevYearTotals: privatePrevYearTotals,
    );
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

  // 現在の月から過去１年分(現在の月を含めた13ヶ月分)の月を取得する
  void generateMonths() {
    final currentMonth = DateTime.now();
    // TODO: 課金: 5年(65ヶ月), 無料: 1年(13ヶ月)
    List<String> months = List.generate(36, (index) {
      final month = DateTime(currentMonth.year, currentMonth.month - index, 1);
      return DateFormat('yyyy/MM').format(month);
    });
    state = state.copyWith(months: months.reversed.toList());
  }
}
