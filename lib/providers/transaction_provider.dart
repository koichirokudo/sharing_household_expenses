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

  Future<void> fetchMonthlyTransactions(String groupId, DateTime month) async {
    try {
      final transactions = await repository.fetchMonthly(groupId, month);
      state = state.copyWith(transactions: transactions);
      groupByVisibility();
      calculateTotalAmounts();
      generateMonths();
    } catch (e) {
      throw Exception('Failed to fetch monthly transactions: $e');
    }
  }

  Future<void> insertTransaction(Transaction transaction) async {
    try {
      await repository.insert(transaction);
      final updateTransactions = [...state.transactions, transaction];
      state = state.copyWith(transactions: updateTransactions);
      calculateTotalAmounts();
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
      calculateTotalAmounts();
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
      calculateTotalAmounts();
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
      calculateTotalAmounts();
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  void groupByVisibility() {
    final transactions = state.transactions;
    final sharedData = transactions.where((transaction) {
      if (transaction.share == true) {
        return true;
      }
      return false;
    }).toList();
    state = state.copyWith(sharedTransactions: sharedData);

    final privateData = transactions.where((transaction) {
      if (transaction.share == false) {
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
