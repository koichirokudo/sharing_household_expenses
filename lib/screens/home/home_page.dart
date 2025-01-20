import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/extensions/nullable_extensions.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:sharing_household_expenses/widgets/title_row.dart';
import 'package:sharing_household_expenses/widgets/total_row.dart';

import '../../providers/auth_state.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/util_provider.dart';
import '../../widgets/prev_row.dart';
import '../group/first_group_invite_page.dart';
import '../profile/user_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  late AuthState auth;

  Widget _buildActionButtons() {
    final auth = ref.watch(authProvider);
    // ログイン状態によって表示を変える
    return IconButton(
      icon: auth.session != null
          ? const Icon(Icons.account_circle)
          : const Icon(Icons.login),
      onPressed: () {
        if (auth.session != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UserPage(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future(
        () async {
          final profileId = ref.read(authProvider).profile?.id;
          final groupId = ref.read(authProvider).profile?.groupId;
          if (profileId != null && groupId != null) {
            // 今月のトランザクションデータを取得
            await ref
                .read(transactionProvider.notifier)
                .fetchMonthlyTransactions(
                  groupId,
                  profileId,
                  DateTime.now(),
                );
            ref.read(transactionProvider.notifier).calculateCurrentTotals();
            // 先月のトランザクションデータを取得
            await ref
                .read(transactionProvider.notifier)
                .fetchPrevMonthlyTransactions(
                  groupId,
                  profileId,
                  ref.read(utilProvider.notifier).getPrevMonth(),
                );
            ref.read(transactionProvider.notifier).calculatePrevMonthTotals();
            return true;
          } else {
            return false;
          }
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularIndicator;
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'エラーが発生しました: ${snapshot.error}',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'データが見つかりません',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        if (snapshot.data == false) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const FirstGroupInvitePage(),
              ),
            );
          }
        }

        final util = ref.read(utilProvider.notifier);

        // rebuild を最小限にする
        final sharedCurrentIncome = ref.watch(
          transactionProvider.select(
            (state) =>
                state.sharedCurrentTotals[TransactionType.income].toSafeInt(),
          ),
        );
        final sharedCurrentExpense = ref.watch(
          transactionProvider.select(
            (state) =>
                state.sharedCurrentTotals[TransactionType.expense].toSafeInt(),
          ),
        );
        final privateCurrentIncome = ref.watch(
          transactionProvider.select(
            (state) =>
                state.privateCurrentTotals[TransactionType.income].toSafeInt(),
          ),
        );
        final privateCurrentExpense = ref.watch(
          transactionProvider.select(
            (state) =>
                state.privateCurrentTotals[TransactionType.expense].toSafeInt(),
          ),
        );

        final sharedPrevMonthIncome = ref.watch(
          transactionProvider.select(
            (state) =>
                state.sharedPrevMonthTotals[TransactionType.income].toSafeInt(),
          ),
        );
        final sharedPrevMonthExpense = ref.watch(
          transactionProvider.select(
            (state) => state.sharedPrevMonthTotals[TransactionType.expense]
                .toSafeInt(),
          ),
        );
        final privatePrevMonthIncome = ref.watch(
          transactionProvider.select(
            (state) => state.privatePrevMonthTotals[TransactionType.income]
                .toSafeInt(),
          ),
        );
        final privatePrevMonthExpense = ref.watch(
          transactionProvider.select(
            (state) => state.privatePrevMonthTotals[TransactionType.expense]
                .toSafeInt(),
          ),
        );

        final sharedComparedPrevMonthIncome = util.calcPrevTotalAmounts(
          sharedCurrentIncome,
          sharedPrevMonthIncome,
        );
        final sharedComparedPrevMonthExpense = util.calcPrevTotalAmounts(
          sharedCurrentExpense,
          sharedPrevMonthExpense,
        );
        final privateComparedPrevMonthIncome = util.calcPrevTotalAmounts(
          privateCurrentIncome,
          privatePrevMonthIncome,
        );
        final privateComparedPrevMonthExpense = util.calcPrevTotalAmounts(
          privateCurrentExpense,
          privatePrevMonthExpense,
        );

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('今月の収支'),
            actions: [
              _buildActionButtons(),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // グループの収支
                Column(
                  children: [
                    TitleRow(shared: true),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 8),
                    TotalRow(
                      label: '収入',
                      amount: sharedCurrentIncome,
                      type: 'income',
                    ),
                    PrevRow(
                      label: '前月比',
                      amount: sharedComparedPrevMonthIncome,
                      type: 'income',
                    ),
                    TotalRow(
                      label: '支出',
                      amount: sharedCurrentExpense,
                      type: 'expense',
                    ),
                    PrevRow(
                      label: '前月比',
                      amount: sharedComparedPrevMonthExpense,
                      type: 'expense',
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // 個人の収支
                Column(
                  children: [
                    TitleRow(shared: false),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 8),
                    TotalRow(
                      label: '収入',
                      amount: privateCurrentIncome,
                      type: 'income',
                    ),
                    PrevRow(
                      label: '前月比',
                      amount: privateComparedPrevMonthIncome,
                      type: 'income',
                    ),
                    TotalRow(
                      label: '支出',
                      amount: privateCurrentExpense,
                      type: 'expense',
                    ),
                    PrevRow(
                      label: '前月比',
                      amount: privateComparedPrevMonthExpense,
                      type: 'expense',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
