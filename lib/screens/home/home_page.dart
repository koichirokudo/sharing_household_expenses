import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/providers/transaction_provider.dart';
import 'package:sharing_household_expenses/screens/sign_in/sign_in.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../models/profile.dart';
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
  late Profile profile;
  late AuthState auth;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      setState(() {
        _isLoading = true;
      });
      final authNotifier = ref.watch(authProvider.notifier);
      await authNotifier.fetchProfile();
      final auth = ref.watch(authProvider);
      if (auth.profile != null) {
        profile = auth.profile!;
      }
      final profileId = auth.profile?.id;
      final groupId = auth.profile?.groupId;
      final transactionNotifier = ref.watch(transactionProvider.notifier);
      final now = DateTime.now();
      if (profileId != null && groupId != null) {
        await transactionNotifier.fetchMonthlyTransactions(
            groupId, now, profileId);
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final auth = ref.watch(authProvider);
    final sharedIncome =
        state.sharedTotalAmounts[TransactionType.income]!.round();
    final sharedExpense =
        state.sharedTotalAmounts[TransactionType.expense]!.round();
    final privateIncome =
        state.privateTotalAmounts[TransactionType.income]!.round();
    final privateExpense =
        state.privateTotalAmounts[TransactionType.expense]!.round();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('今月の収支'),
        actions: [
          // ログイン状態によって表示を変えるアカウントボタンまたはログインボタン
          IconButton(
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
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? circularIndicator
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // グループの収支
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.group,
                                color: Colors.blue,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'グループ',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                      ),
                      const Divider(height: 1, color: Colors.black12),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '収入',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              convertToYenFormat(amount: sharedIncome),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.trending_down,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      '支出',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  convertToYenFormat(amount: sharedExpense),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 個人の収支
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.account_circle,
                                color: Colors.blue,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                '個人',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                      ),
                      const Divider(height: 1, color: Colors.black12),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '収入',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              convertToYenFormat(amount: privateIncome),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.trending_down,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '支出',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              convertToYenFormat(amount: privateExpense),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
