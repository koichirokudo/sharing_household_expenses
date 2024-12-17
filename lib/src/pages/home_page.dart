import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  final Session? session = supabase.auth.currentSession;
  late TransactionService transactionService;

  Future<void> _checkUserGroupStatus() async {
    final userId = supabase.auth.currentUser!.id;
    try {
      final profile =
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

  @override
  void initState() {
    super.initState;
    transactionService = TransactionService(supabase);
    _checkUserGroupStatus();
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
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          '今月の収支',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: 0.3,
                        title: '収入',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: 0.7,
                        title: '支出',
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: 0.3,
                        title: 'グループの収入',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: 0.7,
                        title: 'グループの支出',
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 個人の収支
        Card(
          child: Column(
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
                    const Text(
                      '¥100,000',
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
                    const Text(
                      '¥100,000',
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
        ),
        const SizedBox(height: 8),
        // グループの収支
        Card(
          child: Column(
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
                    const Text(
                      '¥100,000',
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
                    const Text(
                      '¥100,000',
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
        ),
      ]),
    );
  }
}
