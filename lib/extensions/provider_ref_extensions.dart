import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/category_provider.dart';
import 'package:sharing_household_expenses/providers/category_state.dart';
import 'package:sharing_household_expenses/providers/settlement_state.dart';
import 'package:sharing_household_expenses/providers/user_group_provider.dart';
import 'package:sharing_household_expenses/providers/util_provider.dart';

import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../providers/settlement_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/transaction_state.dart';
import '../providers/user_group_state.dart';

extension ProviderRefExtensions on WidgetRef {
  // notifier
  AuthNotifier get authNotifier => watch(authProvider.notifier);

  CategoryNotifier get categoryNotifier => watch(categoryProvider.notifier);

  SettlementNotifier get settlementNotifier =>
      watch(settlementProvider.notifier);

  TransactionNotifier get transactionNotifier =>
      watch(transactionProvider.notifier);

  UserGroupNotifier get userGroupNotifier => watch(userGroupProvider.notifier);

  UtilNotifier get utilNotifier => watch(utilProvider.notifier);

  // state
  AuthState get authState => watch(authProvider);

  CategoryState get categoryState => watch(categoryProvider);

  SettlementState get settlementState => watch(settlementProvider);

  TransactionState get transactionState => watch(transactionProvider);

  UserGroupState get userGroupState => watch(userGroupProvider);

  // variables
  String? get profileId => watch(authProvider).profile?.id;

  String? get groupId => watch(authProvider).profile?.groupId;
}
