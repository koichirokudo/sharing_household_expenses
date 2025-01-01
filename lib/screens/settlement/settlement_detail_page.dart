import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/transaction_service.dart';
import '../../utils/constants.dart';

class SettlementDetailPage extends StatefulWidget {
  final int settlementId;
  final String month;
  final Map<String, dynamic> profile;
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

class SettlementDetailPageState extends State<SettlementDetailPage> {
  bool _isLoading = false;
  late TransactionService transactionService;
  late String month;
  late String selectedDataType;
  late int settlementId;
  late List<Map<String, dynamic>> profiles;
  List<Map<String, dynamic>> transactions = [];
  Map<String, dynamic> profile = {};
  int paymentPerPerson = 0;
  String incomeExpenseType = 'expense';
  Map<String, Map<String, dynamic>> sharedExpenseAmounts = {};
  Map<String, Map<String, dynamic>> sharedIncomeAmounts = {};
  Map<String, Map<String, dynamic>> selfExpenseAmounts = {};
  Map<String, Map<String, dynamic>> selfIncomeAmounts = {};
  int colorValue = 0;
  late bool isSettlement;
  int expenseTotal = 0;
  int incomeTotal = 0;
  Map<String, double> expenseSections = {};
  Map<String, double> incomeSections = {};
  Map<String, Map<String, dynamic>>? settlementData = {};
  List<bool> _selectedType = <bool>[false, true];

  @override
  void initState() {
    super.initState();
    transactionService = TransactionService(supabase);
    settlementId = widget.settlementId;
    profile = widget.profile;
    month = widget.month;
    selectedDataType = widget.selectedDataType;
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    await _getProfiles();
    await _fetchTransactions();
    if (selectedDataType == 'share') {
      // 共有データ用
      _calcShareSettlements(transactions);
      _calcPaymentPerPerson();
      _generateShareSettlementData();
    } else {
      // 個人データ用
      _calcSelfSettlements(transactions);
      _generateSelfSettlementData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  // 清算済みの transaction データを取得する
  Future<void> _fetchTransactions() async {
    try {
      await Future.delayed(Duration(milliseconds: 700));

      final List<Map<String, dynamic>> data = await supabase
          .from('transactions')
          .select('*, categories(id, name), profiles(username)')
          .eq('settlement_id', settlementId);

      setState(() {
        transactions = data;
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
  }

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

  void _calcShareSettlements(List<Map<String, dynamic>> transactions) async {
    // グループ全員のデータを初期化
    for (var item in profiles) {
      sharedExpenseAmounts[item['id']] = {
        'username': item['username'],
        'avatar_url': item['avatar_url'],
        'amount': 0,
      };
      sharedIncomeAmounts[item['id']] = {
        'username': item['username'],
        'avatar_url': item['avatar_url'],
        'amount': 0,
      };
    }

    // 共有データから支出額を計算する
    for (var item in transactions) {
      if (item['type'] == 'expense') {
        String profileId = item['profile_id'];
        double doubleAmount = item['amount'];
        int amount = doubleAmount.round();
        if (sharedExpenseAmounts.containsKey(profileId)) {
          sharedExpenseAmounts[profileId]!['amount'] =
              sharedExpenseAmounts[profileId]!['amount'] + amount;
          expenseTotal = expenseTotal + amount;
        }
      } else {
        String profileId = item['profile_id'];
        double doubleAmount = item['amount'];
        int amount = doubleAmount.round();
        if (sharedIncomeAmounts.containsKey(profileId)) {
          sharedIncomeAmounts[profileId]!['amount'] =
              sharedIncomeAmounts[profileId]!['amount'] + amount;
          incomeTotal = incomeTotal + amount;
        }
      }
    }
  }

  void _calcSelfSettlements(transactions) {
    for (var item in transactions) {
      if (item['type'] == 'expense') {
        final categoryName = item['categories']['name'];
        double doubleAmount = item['amount'];
        int amount = doubleAmount.round();
        if (selfExpenseAmounts.containsKey(categoryName)) {
          selfExpenseAmounts[categoryName]!['amount'] =
              selfExpenseAmounts[categoryName]!['amount'] + amount;
        } else {
          selfExpenseAmounts[categoryName] = {
            'amount': amount,
          };
          expenseTotal = expenseTotal + amount;
        }
      } else {
        final categoryName = item['categories']['name'];
        double doubleAmount = item['amount'];
        int amount = doubleAmount.round();
        if (selfIncomeAmounts.containsKey(categoryName)) {
          selfIncomeAmounts[categoryName]!['amount'] =
              selfIncomeAmounts[categoryName]!['amount'] + amount;
        } else {
          selfIncomeAmounts[categoryName] = {
            'amount': amount,
          };
          incomeTotal = incomeTotal + amount;
        }
      }
    }
  }

  // 共有支出のみの計算処理
  void _calcPaymentPerPerson() {
    paymentPerPerson = sharedExpenseAmounts.isNotEmpty
        ? (expenseTotal / sharedExpenseAmounts.length).round()
        : 0;
    sharedExpenseAmounts.forEach((profileId, item) {
      // 1人当たりの支払額との差を計算
      num difference = paymentPerPerson - item['amount'];
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
        item['payments'] = 0;
        item['role'] = 'neutral';
      }
    });
  }

  void _generateShareSettlementData() {
    String? payer,
        payee,
        payment,
        receive,
        payerAmount,
        payeeAmount,
        payerAvatarUrl,
        payeeAvatarUrl;

    sharedExpenseAmounts.forEach((profileId, data) {
      expenseSections['${data['username']}'] =
          double.parse(data['amount'].toString());
      if (data['role'] == 'payer') {
        payer = data['username'];
        payerAvatarUrl = data['avatar_url'];
        payerAmount = context.convertToYenFormat(amount: data['amount']);
        payment = context.convertToYenFormat(amount: data['payments']);
      } else if (data['role'] == 'payee') {
        payee = data['username'];
        payeeAvatarUrl = data['avatar_url'];
        payeeAmount = context.convertToYenFormat(amount: data['amount']);
        receive = context.convertToYenFormat(amount: data['payments']);
      }
    });

    sharedIncomeAmounts.forEach((profileId, data) {
      incomeSections['${data['username']}'] =
          double.parse(data['amount'].toString());
    });

    // どちらも null でなければ SettlementData 作成
    if (payer != null && payee != null && payment != null && receive != null) {
      settlementData?['payer'] = {
        'role': 'payer',
        'username': payer!,
        'avatarUrl': payerAvatarUrl,
        'advancePayment': payerAmount ?? '0',
        'payment': payment!,
      };
      settlementData?['payee'] = {
        'role': 'payee',
        'username': payee!,
        'avatarUrl': payeeAvatarUrl,
        'advancePayment': payeeAmount ?? '0',
        'payment': receive!,
      };
    } else {
      // 受け渡し情報が無い場合は null のまま
      settlementData = null;
    }
  }

  void _generateSelfSettlementData() {
    selfExpenseAmounts.forEach((categoryName, data) {
      expenseSections['${categoryName}'] =
          double.parse(data['amount'].toString());
    });

    selfIncomeAmounts.forEach((categoryName, data) {
      incomeSections['${categoryName}'] =
          double.parse(data['amount'].toString());
    });
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
                  Text(
                      '${context.convertToYenFormat(amount: paymentPerPerson)}'),
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
    String pieChartCenterText = '';
    if (incomeExpenseType == 'expense' && selectedDataType == 'share') {
      pieChartCenterText =
          '支払合計額: ${context.convertToYenFormat(amount: expenseTotal)}\n'
          '割り勘金額: ${context.convertToYenFormat(amount: paymentPerPerson)}';
    } else if (incomeExpenseType == 'expense' &&
        selectedDataType == 'private') {
      pieChartCenterText =
          '支払合計額: ${context.convertToYenFormat(amount: expenseTotal)}';
    } else if (incomeExpenseType == 'income') {
      pieChartCenterText =
          '収入合計額: ${context.convertToYenFormat(amount: incomeTotal)}';
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('清算結果'),
        ),
        body: circularIndicator,
      );
    }

    if (transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('清算結果'),
        ),
        body: Center(child: Text('データがありません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('清算結果'),
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
                  children: [
                    Text('収入'),
                    Text('支出'),
                  ],
                  isSelected: _selectedType,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
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
                      (incomeExpenseType == 'income' && incomeSections.isEmpty)
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
            const SizedBox(height: 8),
            if (selectedDataType == 'share' && settlementData != null) ...[
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
                      double amount = transactions[index]['amount'];
                      final displayAmount =
                          context.convertToYenFormat(amount: amount.round());

                      final date =
                          DateTime.parse(transactions[index]['date']).toLocal();
                      final transactionDate =
                          DateFormat('yyyy/MM/dd').format(date);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailPage(
                                transaction: transactions[index],
                                profile: profile,
                                isSettlement: true,
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
                                      Text(
                                        transactions[index]['name'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                          '- ${transactions[index]['profiles']['username']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          )),
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
                                            color: transactions[index]
                                                        ['type'] ==
                                                    'income'
                                                ? Colors.green
                                                : Colors.red,
                                            width: 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          transactions[index]['type'] ==
                                                  'income'
                                              ? '収入'
                                              : '支出',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: transactions[index]
                                                        ['type'] ==
                                                    'income'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        transactions[index]['categories']
                                            ['name'],
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
