import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/src/pages/transaction_detail_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class SettlementPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Map<String, dynamic> profile;
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

class SettlementPageState extends State<SettlementPage> {
  bool _isLoading = false;
  late List<Map<String, dynamic>> transactions;
  late List<Map<String, dynamic>> profiles;
  late List<Map<String, dynamic>> expenses;
  late Map<String, dynamic> profile;
  late String month;
  late String selectedDataType;
  int paymentPerPerson = 0;
  int expenseTotal = 0;
  Map<String, Map<String, dynamic>> profileAmounts = {};
  Map<String, Map<String, dynamic>> categoryAmounts = {};
  int colorValue = 0;
  late bool isSettlement;

  @override
  void initState() {
    super.initState();
    // initState 内で widget.transaction を初期化
    transactions = widget.transactions;
    profile = widget.profile;
    month = widget.month;
    isSettlement = widget.isSettlement;
    selectedDataType = widget.selectedDataType;
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    await _getProfiles();
    expenses = transactions
        .where((transaction) => transaction['type'] == 'expense')
        .toList();
    if (selectedDataType == 'share') {
      // 共有データ用の処理
      _calcProfileAmounts(transactions);
      _calcPaymentPerPerson();
    } else {
      // 個人データ用の処理
      // カテゴリごとに計算したものをグラフに表示する？
      _calcCategory(transactions);
    }
    setState(() {
      _isLoading = false;
    });
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

  void _calcProfileAmounts(List<Map<String, dynamic>> transactions) async {
    // グループ全員のデータを初期化
    for (var item in profiles) {
      profileAmounts[item['id']] = {
        'username': item['username'],
        'amount': 0,
      };
    }

    // 共有したデータの中から、ユーザー別の支払い
    for (var item in transactions) {
      if (item['type'] == 'income') {
        continue;
      }
      String profileId = item['profile_id'];
      double doubleAmount = item['amount'];
      int amount = doubleAmount.round();
      if (profileAmounts.containsKey(profileId)) {
        profileAmounts[profileId]!['amount'] =
            profileAmounts[profileId]!['amount'] + amount;
        expenseTotal = expenseTotal + amount;
      }
    }
  }

  void _calcPaymentPerPerson() {
    paymentPerPerson = (expenseTotal / profileAmounts.length).round();
    profileAmounts.forEach((profileId, item) {
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

  void _calcCategory(transactions) {
    for (var item in transactions) {
      if (item['type'] == 'income') {
        continue;
      }
      final categoryName = item['categories']['name'];
      double doubleAmount = item['amount'];
      int amount = doubleAmount.round();
      if (categoryAmounts.containsKey(categoryName)) {
        categoryAmounts[categoryName]!['amount'] =
            categoryAmounts[categoryName]!['amount'] + amount;
      } else {
        categoryAmounts[categoryName] = {
          'amount': amount,
        };
        expenseTotal = expenseTotal + amount;
      }
    }
  }

  Future<void> _settlementConfirm() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(Duration(milliseconds: 700));
      final userId = supabase.auth.currentUser!.id;
      final profiles = await supabase
          .from('profiles')
          .select('group_id')
          .eq('id', userId)
          .single();
      DateTime now = DateTime.now();
      final settlementDate = DateFormat('yyyy/MM').format(now);
      final settlementData = {
        'group_id': profiles['group_id'],
        'visibility': selectedDataType == 'share' ? 'share' : 'private',
        'settlement_date': settlementDate,
        'total_amount': expenseTotal,
        'amount_per_person': paymentPerPerson,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final settlement = await supabase
          .from('settlements')
          .insert(settlementData)
          .select()
          .single();

      List<Map<String, dynamic>> settlementItem = [];
      profileAmounts.forEach((profileId, item) {
        settlementItem.add({
          'settlement_id': settlement['id'],
          'profile_id': profileId,
          'role': item['role'],
          'amount': item['payments'],
          'percentage': 50,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      });
      await supabase.from('settlement_items').insert(settlementItem);

      List<Map<String, dynamic>> transactionIds = [];
      for (var transaction in transactions) {
        transaction.remove('profiles');
        transaction.remove('categories');
        transactionIds.add({
          ...transaction,
          'settlement_id': settlement['id'],
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      await supabase.from('transactions').upsert(transactionIds);

      if (mounted) {
        context.showSnackBar(
            message: '清算を確定しました', backgroundColor: Colors.green);
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: "$error");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selfSettlementConfirm() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(Duration(milliseconds: 700));
      final userId = supabase.auth.currentUser!.id;
      final profiles = await supabase
          .from('profiles')
          .select('group_id')
          .eq('id', userId)
          .single();
      DateTime now = DateTime.now();
      final settlementDate = DateFormat('yyyy/MM').format(now);
      final settlementData = {
        'group_id': profiles['group_id'],
        'settlement_date': settlementDate,
        'total_amount': expenseTotal,
        'amount_per_person': expenseTotal,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final settlement = await supabase
          .from('settlements')
          .insert(settlementData)
          .select()
          .single();

      List<Map<String, dynamic>> settlementItem = [];
      settlementItem.add({
        'settlement_id': settlement['id'],
        'profile_id': profile['id'],
        'role': 'self',
        'amount': expenseTotal,
        'percentage': 100,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await supabase.from('settlement_items').insert(settlementItem);

      List<Map<String, dynamic>> transactionIds = [];
      for (var transaction in transactions) {
        transaction.remove('profiles');
        transaction.remove('categories');
        transactionIds.add({
          ...transaction,
          'settlement_id': settlement['id'],
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      await supabase.from('transactions').upsert(transactionIds);

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

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [];
    double profileTotalAmount =
        profileAmounts.values.fold(0, (sum, data) => sum + data['amount']);
    double categoryTotalAmount =
        categoryAmounts.values.fold(0, (sum, data) => sum + data['amount']);
    String? payer, payee, payment, receive;

    // TODO: random color にするとびみょー
    // TODO: primary color を段階的にする方が楽で綺麗かも
    Color getColorForProfile() {
      // ユーザーに応じた色を返す（例: 一意の色を生成）
      return Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
          .withOpacity(1.0);
    }

    // グラフデータの生成
    if (selectedDataType == 'share') {
      // 共有者同士の合計値
      profileAmounts.forEach((profileId, data) {
        double percentage = (data['amount']) / profileTotalAmount * 100;
        sections.add(
          PieChartSectionData(
              color: getColorForProfile(),
              value: percentage,
              title:
                  '${data['username']}の支出\n${context.convertToYenFormat(amount: data['amount'])}',
              radius: 50),
        );
        if (data['role'] == 'payer') {
          payer = data['username'];
          payment = context.convertToYenFormat(amount: data['payments']);
        } else if (data['role'] == 'payee') {
          payee = data['username'];
          receive = context.convertToYenFormat(amount: data['payments']);
        }
      });
    } else {
      // カテゴリごとの合計値
      categoryAmounts.forEach((categoryName, data) {
        double percentage = (data['amount']) / categoryTotalAmount * 100;
        sections.add(
          PieChartSectionData(
              color: getColorForProfile(),
              value: percentage,
              title:
                  '${categoryName}\n${context.convertToYenFormat(amount: data['amount'])}',
              radius: 50),
        );
      });
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
                  // グラフ
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedDataType == 'share') ...[
                    Center(
                      child: Text(
                        '清算結果',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                          '1人あたりの支払額: ${context.convertToYenFormat(amount: paymentPerPerson)}'),
                    ),
                    const SizedBox(height: 16),
                    if (payer != null &&
                        payee != null &&
                        payment != null &&
                        receive != null)
                      Center(
                        child: Text(
                          '$payer さんは $payee さんに $payment 支払ってください',
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              // ユーザー画像
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/icons/user_icon.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('$payer'),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.trending_flat_rounded, size: 32),
                              Text(
                                '$payment',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              // ユーザー画像
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/icons/user_icon.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('$payee'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // 清算確定ボタン
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
                            '共有された明細',
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
                            final displayAmount = context.convertToYenFormat(
                                amount: amount.round());

                            final date =
                                DateTime.parse(transactions[index]['date'])
                                    .toLocal();
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
