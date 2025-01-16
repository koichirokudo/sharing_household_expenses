import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/providers/auth_state.dart';
import 'package:sharing_household_expenses/providers/settlement_provider.dart';
import 'package:sharing_household_expenses/providers/transaction_provider.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_detail_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../models/profile.dart';
import '../../models/transaction.dart';

class SettlementPage extends ConsumerStatefulWidget {
  final List<Transaction> transactions;
  final Profile profile;
  final String month;
  final bool isSettlement;
  final String selectedDataType;

  const SettlementPage({
    super.key,
    required this.month,
    required this.transactions,
    required this.profile,
    required this.isSettlement,
    required this.selectedDataType,
  });

  @override
  SettlementPageState createState() => SettlementPageState();
}

class SettlementPageState extends ConsumerState<SettlementPage> {
  bool _isLoading = false;
  late List<Transaction> transactions;
  late String month;
  late String selectedDataType;
  String incomeExpenseType = 'expense';
  int expenseTotal = 0;
  int incomeTotal = 0;
  late bool isSettlement;
  Map<String, double> expenseSections = {};
  Map<String, double> incomeSections = {};
  Map<String, Map<String, dynamic>>? settlementData = {};

  late Profile profile;
  late List<Profile>? profiles;
  late AuthState auth;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    // initState 内で widget.transaction を初期化
    transactions = widget.transactions;
    profile = widget.profile;
    month = widget.month;
    isSettlement = widget.isSettlement;
    selectedDataType = widget.selectedDataType;

    Future.microtask(() async {
      final authNotifier = ref.watch(authProvider.notifier);
      await authNotifier.fetchProfile();
      await authNotifier.fetchProfiles();
      auth = ref.watch(authProvider);
      final groupId = profile.groupId;
      if (groupId == null) {
        return;
      }
      profiles = auth.profiles;

      final settlementNotifier = ref.watch(settlementProvider.notifier);
      if (selectedDataType == 'shared') {
        await settlementNotifier.initializeShared(transactions, profiles);
      } else if (selectedDataType == 'private') {
        settlementNotifier.initializePrivate(transactions);
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sharedSettlementConfirm() async {
    try {
      final state = ref.watch(settlementProvider);

      final settlementData = {
        'group_id': profile.groupId,
        'visibility': 'shared',
        'settlement_date': month,
        'income_total_amount': state.incomeTotal,
        'expense_total_amount': state.expenseTotal,
        'amount_per_person': state.amountPerPerson,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await ref
          .watch(settlementProvider.notifier)
          .saveSettlement(settlementData);
      final settlementId = ref.watch(settlementProvider).settlement?.id;

      List<Map<String, dynamic>> settlementItems = [];
      state.sharedExpenseAmounts.forEach((profileId, item) {
        settlementItems.add({
          'settlement_id': settlementId,
          'profile_id': profileId,
          'role': item['role'],
          'amount': item['payments'],
          'percentage': 50,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      });

      await ref
          .watch(settlementProvider.notifier)
          .saveSettlementItems(settlementItems);

      List<Map<String, dynamic>> transactionIds = [];
      for (var transaction in transactions) {
        transactionIds.add({
          ...transaction.toMapForUpdate(),
          'settlement_id': settlementId,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      await ref
          .watch(transactionProvider.notifier)
          .upsertTransaction(transactionIds);

      if (mounted) {
        context.showSnackBar(
            message: '清算を確定しました', backgroundColor: Colors.green);
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
  }

  Future<void> _privateSettlementConfirm() async {
    try {
      final state = ref.watch(settlementProvider);
      DateTime now = DateTime.now();
      final settlementDate = DateFormat('yyyy/MM').format(now);
      final settlementData = {
        'group_id': profile.groupId,
        'visibility': 'private',
        'settlement_date': settlementDate,
        'income_total_amount': state.incomeTotal,
        'expense_total_amount': state.expenseTotal,
        'amount_per_person': state.expenseTotal,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await ref
          .watch(settlementProvider.notifier)
          .saveSettlement(settlementData);
      final settlementId = ref.watch(settlementProvider).settlement?.id;

      List<Map<String, dynamic>> settlementItems = [];
      settlementItems.add({
        'settlement_id': settlementId,
        'profile_id': profile.id,
        'role': 'self',
        'amount': state.expenseTotal,
        'percentage': 100,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await ref
          .watch(settlementProvider.notifier)
          .saveSettlementItems(settlementItems);

      List<Map<String, dynamic>> transactionIds = [];
      for (var transaction in transactions) {
        transactionIds.add({
          ...transaction.toMapForUpdate(),
          'settlement_id': settlementId,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      await ref
          .watch(transactionProvider.notifier)
          .upsertTransaction(transactionIds);

      if (mounted) {
        context.showSnackBar(
            message: '清算を確定しました', backgroundColor: Colors.green);
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
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
                    ),
                  ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              ],
            ),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayTotalAmounts() {
    final state = ref.watch(settlementProvider);

    final incomeTotal = convertToYenFormat(
      amount: state.incomeTotal,
    );
    final expenseTotal = convertToYenFormat(
      amount: state.expenseTotal,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 1.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                '収入',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              incomeTotal,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 1.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                '支出',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              expenseTotal,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementProvider);
    Map<String, dynamic> payer = {};
    Map<String, dynamic> payee = {};

    setState(() {
      payer = state.payer;
      payee = state.payee;
    });

    if (_isLoading || payer.isEmpty || payee.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('清算'),
        ),
        body: circularIndicator,
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('清算'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            if (selectedDataType == 'shared') ...[
              _buildSettlementCard(payer),
              const SizedBox(height: 16),
              _buildSettlementCard(payee),
            ],
            const SizedBox(height: 16),
            if (!isSettlement)
              Center(
                child: SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text('清算確定処理'),
                            content: Text('確定すると変更することはできません。よろしいですか？'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('はい'),
                                onPressed: () {
                                  Navigator.of(dialogContext)
                                      .pop(); // Dismiss alert dialog
                                  if (selectedDataType == 'shared') {
                                    _sharedSettlementConfirm();
                                  } else {
                                    _privateSettlementConfirm();
                                  }
                                },
                              ),
                              TextButton(
                                child: Text('いいえ'),
                                onPressed: () {
                                  Navigator.of(dialogContext)
                                      .pop(); // Dismiss alert dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 50),
                    ),
                    child: const Text('清算を確定する'),
                  ),
                ),
              ),
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
                      final username = transactions[index].profile?.username;
                      final categoryName = transactions[index].category?.name;
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (transactions[index].name != '') ...[
                                        Text(
                                          '${transactions[index].name} -',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        username,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                          vertical: 1.0,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: transactions[index].type ==
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
                                            color: transactions[index].type ==
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
