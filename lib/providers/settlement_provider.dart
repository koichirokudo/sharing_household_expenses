import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/constants/settlement_visibility.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/models/profile.dart';
import 'package:sharing_household_expenses/models/transaction.dart';
import 'package:sharing_household_expenses/providers/settlement_state.dart';
import 'package:sharing_household_expenses/repositories/settlement_repository.dart';

import '../utils/constants.dart';

final settlementProvider =
    StateNotifierProvider<SettlementNotifier, SettlementState>(
  (ref) => SettlementNotifier(SettlementRepository()),
);

class SettlementNotifier extends StateNotifier<SettlementState> {
  final SettlementRepository repository;

  SettlementNotifier(this.repository)
      : super(
          SettlementState(
            isLoading: false,
            isSettlementComplete: false,
            settlement: null,
            settlements: [],
            sharedSettlements: [],
            privateSettlements: [],
            settlementItems: [],
            sharedIncomeAmounts: {},
            sharedExpenseAmounts: {},
            privateIncomeAmounts: {},
            privateExpenseAmounts: {},
            payer: {},
            payee: {},
            expenseTotal: 0,
            incomeTotal: 0,
            amountPerPerson: 0,
            years: [],
          ),
        );

  Future<void> initializeShared(
      List<Transaction> transactions, List<Profile>? profiles) async {
    if (profiles != null) {
      await calcSharedSettlements(transactions, profiles);
    }
  }

  void initializePrivate(List<Transaction> transactions) {
    calcPrivateSettlements(transactions);
  }

  Future<void> fetchYearlySettlements(String groupId, DateTime now) async {
    state = state.copyWith(isLoading: true);
    try {
      final settlements = await repository.fetchYearly(groupId, now);
      state = state.copyWith(settlements: settlements);
      groupByVisibility();
    } catch (e) {
      throw Exception('Failed to fetch yearly settlements: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveSettlement(Map<String, dynamic> settlementData) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.saveSettlement(settlementData);
      state = state.copyWith(isSettlementComplete: true, settlement: response);
    } catch (e) {
      throw Exception('Failed to confirm settlement: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveSettlementItems(
      List<Map<String, dynamic>> settlementItemData) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.saveSettlementItems(settlementItemData);
      state = state.copyWith(settlementItems: response);
    } catch (e) {
      throw Exception('Failed to confirm settlement: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Map<String, dynamic>> checkSettlement(
      String visibility, String month) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.checkSettlement(visibility, month);
      return response;
    } catch (e) {
      throw Exception('Failed to check settlement: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 共有データの清算
  Future<void> calcSharedSettlements(
      List<Transaction> transactions, List<Profile> profiles) async {
    state = state.copyWith(isLoading: true);
    try {
      final sharedIncomeAmounts = <String, Map<String, dynamic>>{};
      final sharedExpenseAmounts = <String, Map<String, dynamic>>{};
      int incomeTotal = 0;
      int expenseTotal = 0;

      // グループ全員のデータを初期化
      for (var item in profiles) {
        sharedExpenseAmounts[item.id] = {
          'username': item.username,
          'avatar_url': item.avatarUrl,
          'amount': 0,
        };
        sharedIncomeAmounts[item.id] = {
          'username': item.username,
          'avatar_url': item.avatarUrl,
          'amount': 0,
        };
      }

      // 共有データから支出額を計算する
      for (var item in transactions) {
        if (item.type == TransactionType.expense) {
          String profileId = item.profileId;
          double doubleAmount = item.amount;
          int amount = doubleAmount.round();

          if (sharedExpenseAmounts.containsKey(profileId)) {
            sharedExpenseAmounts[profileId]?['amount'] =
                sharedExpenseAmounts[profileId]?['amount'] + amount;
            expenseTotal = expenseTotal + amount;
          }

          final categoryName = item.category?.name;
          if (categoryName == null) {
            return;
          }
        } else {
          String profileId = item.profileId;
          double doubleAmount = item.amount;
          int amount = doubleAmount.round();

          if (sharedIncomeAmounts.containsKey(profileId)) {
            sharedIncomeAmounts[profileId]?['amount'] =
                sharedIncomeAmounts[profileId]?['amount'] + amount;
            incomeTotal = incomeTotal + amount;
          }
        }
      }

      // 1人あたりの支払額（割り勘金額）
      final amountPerPerson =
          (expenseTotal / sharedExpenseAmounts.length).round();

      // 1人あたりの支払額との差額を計算
      sharedExpenseAmounts.forEach((profileId, item) {
        num difference = amountPerPerson - item['amount'];
        if (difference < 0) {
          // 基準より多く支払っている
          item['payments'] = -difference; // 正の値に変換
          // 受取人
          item['role'] = 'payee';
        } else if (difference > 0) {
          // 基準より少ない額を支払っている
          item['payments'] = difference;
          // 支払人
          item['role'] = 'payer';
        } else {
          // even
          item['payments'] = 0;
          item['role'] = 'even';
        }
      });

      Map<String, dynamic> payer = {};
      Map<String, dynamic> payee = {};

      sharedExpenseAmounts.forEach((profileId, data) {
        if (data['role'] == 'payer') {
          payer = {
            'role': 'payer',
            'username': data['username'],
            'avatarUrl': data['avatar_url'],
            'advancePayment': convertToYenFormat(amount: data['amount']),
            'payment': convertToYenFormat(amount: data['payments']),
          };
        } else if (data['role'] == 'payee') {
          payee = {
            'role': 'payee',
            'username': data['username'],
            'avatarUrl': data['avatar_url'],
            'advancePayment': convertToYenFormat(amount: data['amount']),
            'receive': convertToYenFormat(amount: data['payments']),
          };
        } else {
          // TODO: even のときにどうするか
        }
      });

      state = state.copyWith(
        sharedExpenseAmounts: sharedExpenseAmounts,
        sharedIncomeAmounts: sharedIncomeAmounts,
        expenseTotal: expenseTotal,
        incomeTotal: incomeTotal,
        amountPerPerson: amountPerPerson,
        payer: payer,
        payee: payee,
      );
    } catch (e) {
      throw Exception('Failed to calculate shared settlements: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 個人データの清算
  void calcPrivateSettlements(List<Transaction> transactions) {
    final privateIncomeAmounts = <String, Map<String, dynamic>>{};
    final privateExpenseAmounts = <String, Map<String, dynamic>>{};
    int incomeTotal = 0;
    int expenseTotal = 0;

    for (var item in transactions) {
      if (item.type == TransactionType.expense) {
        final categoryName = item.category?.name;
        if (categoryName == null) {
          return;
        }
        double doubleAmount = item.amount;
        int amount = doubleAmount.round();
        if (privateExpenseAmounts.containsKey(categoryName)) {
          privateExpenseAmounts[categoryName]?['amount'] =
              privateExpenseAmounts[categoryName]?['amount'] + amount;
        } else {
          privateExpenseAmounts[categoryName] = {
            'amount': amount,
          };
          expenseTotal = expenseTotal + amount;
        }
      } else {
        final categoryName = item.category?.name;
        if (categoryName == null) {
          return;
        }
        double doubleAmount = item.amount;
        int amount = doubleAmount.round();
        if (privateIncomeAmounts.containsKey(categoryName)) {
          privateIncomeAmounts[categoryName]?['amount'] =
              privateIncomeAmounts[categoryName]?['amount'] + amount;
        } else {
          privateIncomeAmounts[categoryName] = {
            'amount': amount,
          };
          incomeTotal = incomeTotal + amount;
        }
      }
    }

    state = state.copyWith(
      privateExpenseAmounts: privateExpenseAmounts,
      privateIncomeAmounts: privateIncomeAmounts,
      expenseTotal: expenseTotal,
      incomeTotal: incomeTotal,
    );
  }

  void generateYears() {
    final now = DateTime.now();
    final years = List.generate(2, (index) {
      final year = DateTime(now.year - index, now.month, 1);
      return DateFormat('yyyy').format(year);
    });
    state = state.copyWith(years: years.reversed.toList());
  }

  void groupByVisibility() {
    final settlements = state.settlements;
    final sharedData = settlements.where((settlement) {
      if (settlement.visibility == SettlementVisibility.shared) {
        return true;
      }
      return false;
    }).toList();
    state = state.copyWith(sharedSettlements: sharedData);

    final privateData = settlements.where((settlement) {
      if (settlement.visibility == SettlementVisibility.private) {
        return true;
      }
      return false;
    }).toList();
    state = state.copyWith(privateSettlements: privateData);
  }

  void generate() {}
}
