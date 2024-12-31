import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/services/transaction_service.dart';
import 'package:sharing_household_expenses/src/pages/first_group_invite_page.dart';
import 'package:sharing_household_expenses/src/pages/user_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isLoading = false;
  final Session? session = supabase.auth.currentSession;
  late TransactionService transactionService;
  late List<Map<String, dynamic>> transactions = [];
  late List<Map<String, dynamic>> profiles = [];
  late Map<String, dynamic> profile = {};
  final userId = supabase.auth.currentUser!.id;
  double sharedIncome = 0;
  double sharedExpense = 0;
  double privateIncome = 0;
  double privateExpense = 0;
  String sharedIncomeAmount = '';
  String sharedExpenseAmount = '';
  String privateIncomeAmount = '';
  String privateExpenseAmount = '';

  Future<void> _getProfiles() async {
    try {
      await Future.delayed(Duration(milliseconds: 700));
      profiles = await supabase
          .from('profiles')
          .select()
          .eq('group_id', profile['group_id']);
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
  }

  Future<void> _checkUserGroupStatus() async {
    final userId = supabase.auth.currentUser!.id;
    try {
      profile =
          await supabase.from('profiles').select('*').eq('id', userId).single();

      if (profile['group_id'] == null) {
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const FirstGroupInvitePage()));
        }
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final currentMonth = DateFormat('yyyy/MM').format(DateTime.now());
      final List<Map<String, dynamic>>? data =
          await transactionService.fetchMonthlyData(
              profile['group_id'], convertMonthToDateTime(currentMonth));
      setState(() {
        transactions = data ?? [];
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
  }

  void _calcTotal() {
    for (var item in transactions) {
      if (item['share'] == true) {
        if (item['type'] == 'income') {
          sharedIncome += item['amount'];
        } else if (item['type'] == 'expense') {
          sharedExpense += item['amount'];
        }
      } else {
        if (item['type'] == 'income') {
          privateIncome += item['amount'];
        } else if (item['type'] == 'expense') {
          privateExpense += item['amount'];
        }
      }
    }
    sharedIncomeAmount =
        context.convertToYenFormat(amount: sharedIncome.round());
    sharedExpenseAmount =
        context.convertToYenFormat(amount: sharedExpense.round());
    privateIncomeAmount =
        context.convertToYenFormat(amount: privateIncome.round());
    privateExpenseAmount =
        context.convertToYenFormat(amount: privateExpense.round());
  }

  @override
  void initState() {
    super.initState;
    transactionService = TransactionService(supabase);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkUserGroupStatus();
    await _fetchTransactions();
    _calcTotal();
  }

  // TODO: サーバーからデータを取得する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('シェア家計簿'),
        actions: [
          // ログイン状態によって表示を変えるアカウントボタンまたはログインボタン
          IconButton(
            icon: session != null
                ? const Icon(Icons.account_circle)
                : const Icon(Icons.login),
            onPressed: () {
              if (session != null) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UserPage()));
              } else {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 16),
          const Text(
            '今月の収支',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // 個人の収支
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      sharedIncomeAmount,
                      style: TextStyle(
                        fontSize: 24,
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      sharedExpenseAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // グループの収支
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      privateIncomeAmount,
                      style: TextStyle(
                        fontSize: 24,
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      privateExpenseAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
