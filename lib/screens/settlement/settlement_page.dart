import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sharing_household_expenses/constants/settlement_visibility.dart';
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
  late List<Map<String, dynamic>> expenses;
  late String month;
  late String selectedDataType;
  String incomeExpenseType = 'expense';
  int paymentPerPerson = 0;
  int expenseTotal = 0;
  int incomeTotal = 0;
  Map<String, Map<String, dynamic>> sharedExpenseAmounts = {};
  Map<String, Map<String, dynamic>> sharedIncomeAmounts = {};
  Map<String, Map<String, dynamic>> selfExpenseAmounts = {};
  Map<String, Map<String, dynamic>> selfIncomeAmounts = {};
  int colorValue = 0;
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
      profiles = auth.profiles;
      final settlementNotifier = ref.watch(settlementProvider.notifier);
      if (selectedDataType == 'shared') {
        await settlementNotifier.initializeShared(transactions, profiles);
      } else if (selectedDataType == 'private') {
        settlementNotifier.initializePrivate(transactions);
      }
    });
  }

  Future<void> _settlementConfirm() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final settlementData = {
        'group_id': profile.groupId,
        'visibility': selectedDataType == 'shared'
            ? SettlementVisibility.shared
            : SettlementVisibility.private,
        'settlement_date': month,
        'income_total_amount': incomeTotal,
        'expense_total_amount': expenseTotal,
        'amount_per_person': paymentPerPerson,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await ref
          .watch(settlementProvider.notifier)
          .saveSettlement(settlementData);
      final settlementId = ref.watch(settlementProvider).settlement?.id;

      List<Map<String, dynamic>> settlementItems = [];
      sharedExpenseAmounts.forEach((profileId, item) {
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
          .updateMultipleTransaction(transactionIds);

      if (mounted) {
        context.showSnackBar(
            message: '清算を確定しました', backgroundColor: Colors.green);
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // todo: settlement_provider
  Future<void> _selfSettlementConfirm() async {
    try {
      setState(() {
        _isLoading = true;
      });

      DateTime now = DateTime.now();
      final settlementDate = DateFormat('yyyy/MM').format(now);
      final settlementData = {
        'group_id': profile.groupId,
        'visibility': 'private',
        'settlement_date': settlementDate,
        'income_total_amount': incomeTotal,
        'expense_total_amount': expenseTotal,
        'amount_per_person': expenseTotal,
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
        'amount': expenseTotal,
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
          .updateMultipleTransaction(transactionIds);

      if (mounted) {
        context.showSnackBar(
            message: '清算を確定しました', backgroundColor: Colors.green);
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSettlementCard(data) {
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
                  Text(
                    convertToYenFormat(amount: paymentPerPerson),
                  ),
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
                  Text('自分が支払った金額'),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  Text(data['role'] == 'payer' ? '清算で支払う金額' : '清算で受け取る金額'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${data['payment']}'),
                  const SizedBox(width: 16),
                ],
              )
            ])
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementProvider);
    if (selectedDataType == 'shared') {
      incomeSections = state.sharedIncomeSections;
      expenseSections = state.sharedExpenseSections;
    } else {
      incomeSections = state.privateIncomeSections;
      expenseSections = state.privateExpenseSections;
    }
    String pieChartCenterText = '';
    if (incomeExpenseType == 'expense' && selectedDataType == 'share') {
      pieChartCenterText =
          '支払合計額: ${convertToYenFormat(amount: expenseTotal)}\n'
          '割り勘金額: ${convertToYenFormat(amount: paymentPerPerson)}';
    } else if (incomeExpenseType == 'expense' &&
        selectedDataType == 'private') {
      pieChartCenterText = '支払合計額: ${convertToYenFormat(amount: expenseTotal)}';
    } else if (incomeExpenseType == 'income') {
      pieChartCenterText = '収入合計額: ${convertToYenFormat(amount: incomeTotal)}';
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('清算'),
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
                  const SizedBox(height: 8),
                  // トグルボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < _selectedType.length; i++) {
                              _selectedType[i] = i == index;
                            }
                            if (index == 0) {
                              incomeExpenseType = 'income';
                            } else {
                              incomeExpenseType = 'expense';
                            }
                          });
                        },
                        isSelected: _selectedType,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 80.0,
                        ),
                        children: [
                          Text('収入'),
                          Text('支出'),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  // グラフ
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: (incomeExpenseType == 'expense' &&
                                expenseSections.isEmpty) ||
                            (incomeExpenseType == 'income' &&
                                incomeSections.isEmpty)
                        ? Center(
                            child: Text(
                              'データがありません',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : PieChart(
                            dataMap: incomeExpenseType == 'expense'
                                ? expenseSections
                                : incomeSections,
                            legendOptions: LegendOptions(
                              legendPosition: LegendPosition.left,
                            ),
                            chartValuesOptions: ChartValuesOptions(
                              decimalPlaces: 0,
                              showChartValuesInPercentage: false,
                              showChartValuesOutside: true,
                            ),
                            formatChartValues: (value) {
                              return NumberFormat.currency(
                                      locale: 'ja_JP', symbol: '¥')
                                  .format(value);
                            },
                            chartLegendSpacing: 48,
                            chartType: ChartType.ring,
                            centerText: pieChartCenterText,
                          ),
                  ),
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
                                        if (selectedDataType == 'share') {
                                          _settlementConfirm();
                                        } else {
                                          _selfSettlementConfirm();
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
                  const SizedBox(height: 8),
                  if (selectedDataType == 'share' &&
                      settlementData != null) ...[
                    _buildSettlementCard(settlementData?['payer']),
                    const SizedBox(height: 8),
                    _buildSettlementCard(settlementData?['payee']),
                  ],
                  const SizedBox(height: 8),
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
