import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/extensions/nullable_extensions.dart';
import 'package:sharing_household_expenses/extensions/provider_ref_extensions.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../providers/auth_state.dart';
import '../group/first_group_invite_page.dart';
import '../profile/user_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  bool _isLoading = false;
  late AuthState auth;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      setState(() {
        _isLoading = true;
      });
      await ref.authNotifier.fetchProfile();
      await ref.authNotifier.fetchProfiles();
      final profileId = ref.profileId;
      final groupId = ref.groupId;
      if (profileId != null && groupId != null) {
        await ref.transactionNotifier.fetchMonthlyTransactions(
          groupId,
          profileId,
          DateTime.now(),
        );
        ref.transactionNotifier.calculateCurrentTotals();
        await ref.transactionNotifier.fetchPrevMonthlyTransactions(
          groupId,
          profileId,
          ref.utilNotifier.getPrevMonth(),
        );
        ref.transactionNotifier.calculatePrevMonthTotals();
        await ref.transactionNotifier.fetchPrevYearlyTransactions(
          groupId,
          profileId,
          ref.utilNotifier.getPrevYear(),
        );
        ref.transactionNotifier.calculatePrevYearTotals();
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const FirstGroupInvitePage(),
            ),
          );
        }
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  Color _determineTextColor(int amount, String type) {
    if (amount == 0) {
      return Colors.grey;
    }

    if (type == 'income') {
      return amount < 0 ? Colors.green : Colors.red;
    } else if (type == 'expense') {
      return amount > 0 ? Colors.red : Colors.green;
    }

    return Colors.black;
  }

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

  Widget _buildTitleRow(bool isGroup) {
    final profile = ref.authState.profile;
    final profiles = ref.authState.profiles;
    final avatarUrl = profile?.avatarUrl;
    final username = profile?.username;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isGroup) ...[
            ...?profiles?.map((item) {
              return Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: item.avatarUrl != null
                        ? NetworkImage(item.avatarUrl.toString())
                        : AssetImage('assets/icons/user_icon.png'),
                  ),
                ),
              );
            }),
          ] else ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: avatarUrl != null
                      ? NetworkImage(avatarUrl.toString())
                      : AssetImage('assets/icons/user_icon.png'),
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Text(
            isGroup ? 'グループ' : (username ?? '個人'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTotalRow(int amount, String type) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              type == 'income'
                  ? Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 32,
                    )
                  : Icon(
                      Icons.trending_down,
                      color: Colors.red,
                      size: 32,
                    ),
              const SizedBox(width: 16),
              Text(
                type == 'income' ? '収入' : '支出',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            convertToYenFormat(amount: amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrevRow(int amount, bool isMonth, String type) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 16.0, left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 48),
              Text(
                isMonth ? '前月比' : '前年比',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            amount > 0
                ? '+${convertToYenFormat(amount: amount)}'
                : convertToYenFormat(amount: amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _determineTextColor(amount, type),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final util = ref.utilNotifier;
    final state = ref.transactionState;

    final sharedCurrentIncome =
        state.sharedCurrentTotals[TransactionType.income].toSafeInt();
    final sharedCurrentExpense =
        state.sharedCurrentTotals[TransactionType.expense].toSafeInt();
    final privateCurrentIncome =
        state.privateCurrentTotals[TransactionType.income].toSafeInt();
    final privateCurrentExpense =
        state.privateCurrentTotals[TransactionType.expense].toSafeInt();

    final sharedPrevMonthIncome = util.calcPrevTotalAmounts(
      sharedCurrentIncome,
      state.sharedPrevMonthTotals[TransactionType.income].toSafeInt(),
    );
    final sharedPrevMonthExpense = util.calcPrevTotalAmounts(
      sharedCurrentExpense,
      state.sharedPrevMonthTotals[TransactionType.expense].toSafeInt(),
    );
    final privatePrevMonthIncome = util.calcPrevTotalAmounts(
      privateCurrentIncome,
      state.privatePrevMonthTotals[TransactionType.income].toSafeInt(),
    );
    final privatePrevMonthExpense = util.calcPrevTotalAmounts(
      privateCurrentExpense,
      state.privatePrevMonthTotals[TransactionType.expense].toSafeInt(),
    );

    final sharedPrevYearIncome = util.calcPrevTotalAmounts(
      sharedCurrentIncome,
      state.sharedPrevYearTotals[TransactionType.income].toSafeInt(),
    );
    final sharedPrevYearExpense = util.calcPrevTotalAmounts(
      sharedCurrentExpense,
      state.sharedPrevYearTotals[TransactionType.expense].toSafeInt(),
    );
    final privatePrevYearIncome = util.calcPrevTotalAmounts(
      privateCurrentIncome,
      state.privatePrevYearTotals[TransactionType.income].toSafeInt(),
    );
    final privatePrevYearExpense = util.calcPrevTotalAmounts(
      privateCurrentExpense,
      state.privatePrevYearTotals[TransactionType.expense].toSafeInt(),
    );

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('今月の収支'),
          actions: [
            _buildActionButtons(),
          ],
        ),
        body: circularIndicator,
      );
    }

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
                _buildTitleRow(true),
                const Divider(height: 1, color: Colors.black12),
                _buildCurrentTotalRow(sharedCurrentIncome, 'income'),
                _buildPrevRow(sharedPrevMonthIncome, true, 'income'),
                _buildPrevRow(sharedPrevYearIncome, false, 'income'),
                _buildCurrentTotalRow(sharedCurrentExpense, 'expense'),
                _buildPrevRow(sharedPrevMonthExpense, true, 'expense'),
                _buildPrevRow(sharedPrevYearExpense, false, 'expense'),
              ],
            ),
            // 個人の収支
            Column(
              children: [
                _buildTitleRow(false),
                const Divider(height: 1, color: Colors.black12),
                _buildCurrentTotalRow(privateCurrentIncome, 'income'),
                _buildPrevRow(privatePrevMonthIncome, true, 'income'),
                _buildPrevRow(privatePrevYearIncome, false, 'income'),
                _buildCurrentTotalRow(privateCurrentExpense, 'expense'),
                _buildPrevRow(privatePrevMonthExpense, true, 'expense'),
                _buildPrevRow(privatePrevYearExpense, false, 'expense'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
