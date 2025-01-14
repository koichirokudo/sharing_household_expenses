import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/transaction_type.dart';
import '../../models/profile.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settlement_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';

class SettlementDetailPage extends ConsumerStatefulWidget {
  final String settlementId;
  final String month;
  final Profile profile;
  final String selectedDataType;

  const SettlementDetailPage({
    super.key,
    required this.settlementId,
    required this.profile,
    required this.month,
    required this.selectedDataType,
  });

  @override
  SettlementDetailPageState createState() => SettlementDetailPageState();
}

class SettlementDetailPageState extends ConsumerState<SettlementDetailPage> {
  final bool _isLoading = false;
  late String month;
  late String selectedDataType;
  late String settlementId;
  late List<Transaction> transactions = [];
  String incomeExpenseType = 'expense';
  int expenseTotal = 0;
  int incomeTotal = 0;
  late bool isSettlement;
  Map<String, double> expenseSections = {};
  Map<String, double> incomeSections = {};
  Map<String, Map<String, dynamic>>? settlementData = {};

  final List<bool> _selectedType = <bool>[false, true];
  late Profile profile;
  late List<Profile>? profiles;
  late AuthState auth;

  @override
  void initState() {
    super.initState();
    settlementId = widget.settlementId;
    profile = widget.profile;
    month = widget.month;
    selectedDataType = widget.selectedDataType;

    Future.microtask(() async {
      final authNotifier = ref.watch(authProvider.notifier);
      await authNotifier.fetchProfile();
      await authNotifier.fetchProfiles();
      final auth = ref.watch(authProvider);
      final transactionNotifier = ref.watch(transactionProvider.notifier);
      await transactionNotifier
          .fetchMonthlyTransactionsBySettlement(settlementId);
      setState(() {
        profiles = auth.profiles;
        transactions = ref.watch(transactionProvider).transactions;
      });
      final settlementNotifier = ref.watch(settlementProvider.notifier);
      if (selectedDataType == 'shared') {
        await settlementNotifier.initializeShared(transactions, profiles);
      } else if (selectedDataType == 'private') {
        settlementNotifier.initializePrivate(transactions);
      }
    });
  }

  Widget _buildSettlementCard(data) {
    final state = ref.watch(settlementProvider);
    final amountPerPerson = state.amountPerPerson;

    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                // ユーザー画像
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: data['avatarUrl'] != null
                            ? NetworkImage(data['avatarUrl'])
                            : AssetImage('assets/icons/user_icon.png'),
                      )),
                ),
                const SizedBox(width: 8),
                // 支払人
                Text('${data['username']}'),
              ],
            ),
            const Divider(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  Text('割り勘金額'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(convertToYenFormat(amount: amountPerPerson)),
                  const SizedBox(width: 16),
                ],
              )
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  Text('立替金額'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${data['advancePayment']}'),
                  const SizedBox(width: 16),
                ],
              )
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      data['role'] == 'payer' ? '清算で支払う金額' : '清算で受け取る金額',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      data['role'] == 'payer'
                          ? data['payment']
                          : data['receive'],
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementProvider);
    final payer = state.payer;
    final payee = state.payee;

    if (transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('清算結果'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('清算結果'),
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(128.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16.0),
                    color: const Color(0x002a2a2a),
                    height: 60,
                    child: Text(
                      month,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedDataType == 'shared') ...[
                    _buildSettlementCard(payer),
                    const SizedBox(height: 16),
                    _buildSettlementCard(payee),
                  ],
                  const SizedBox(height: 16),
                  // 共有された明細の一覧
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16.0),
                          child: const Text(
                            '共有明細一覧',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.black12),
                        // リスト部分
                        ListView.builder(
                          shrinkWrap: true,
                          // 必須: ListViewをColumn内で展開可能にする
                          physics: const NeverScrollableScrollPhysics(),
                          // 外側のスクロールビューに依存
                          padding: const EdgeInsets.all(16.0),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            double amount = transactions[index].amount;
                            final displayAmount = convertToYenFormat(
                              amount: amount.round(),
                            );
                            final date = DateTime.parse(
                              transactions[index].date.toString(),
                            ).toLocal();
                            final transactionDate =
                                DateFormat('yyyy/MM/dd').format(date);
                            final username =
                                transactions[index].profile?.username;
                            final categoryName =
                                transactions[index].subCategory?.name;
                            if (username == null || categoryName == null) {
                              return Text('データがありません');
                            }
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionDetailPage(
                                      transaction: transactions[index],
                                      profile: profile,
                                      isSettlement: false,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 80,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black12,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              transactions[index].name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '- $username',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              transactionDate,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4.0,
                                                vertical: 1.0,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: transactions[index]
                                                              .type ==
                                                          TransactionType.income
                                                      ? Colors.green
                                                      : Colors.red,
                                                  width: 0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              child: Text(
                                                transactions[index].type ==
                                                        TransactionType.income
                                                    ? '収入'
                                                    : '支出',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: transactions[index]
                                                              .type ==
                                                          TransactionType.income
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              categoryName,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Text(
                                      displayAmount,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
