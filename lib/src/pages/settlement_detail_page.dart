import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/src/pages/transaction_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/transaction_service.dart';
import '../../utils/constants.dart';

class SettlementDetailPage extends StatefulWidget {
  final int settlementId;
  final String month;
  final Map<String, dynamic> profile;

  const SettlementDetailPage({
    super.key,
    required this.settlementId,
    required this.profile,
    required this.month,
  });

  @override
  SettlementDetailPageState createState() => SettlementDetailPageState();
}

class SettlementDetailPageState extends State<SettlementDetailPage> {
  bool _isLoading = false;
  late TransactionService transactionService;
  late String month;
  late int settlementId;
  List<Map<String, dynamic>> transactions = [];
  Map<String, dynamic> profile = {};
  int paymentPerPerson = 0;
  int expenseTotal = 0;
  Map<String, Map<String, dynamic>> profileAmounts = {};
  int colorValue = 0;
  late bool isSettlement;

  @override
  void initState() {
    super.initState();
    transactionService = TransactionService(supabase);
    settlementId = widget.settlementId;
    profile = widget.profile;
    month = widget.month;
    _fetchTransactions();
  }

  // 清算済みの transaction データを取得する
  Future<void> _fetchTransactions() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(milliseconds: 700));

      final List<Map<String, dynamic>> data = await supabase
          .from('transactions')
          .select('*, categories(id, name), profiles(username)')
          .eq('settlement_id', settlementId);

      setState(() {
        transactions = data;
      });

      _calcProfileAmounts(transactions);
      _calcPaymentPerPerson();
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: "$error");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calcProfileAmounts(List<Map<String, dynamic>> transactions) {
    // 共有したデータの中から、ユーザー別の支払い
    for (var item in transactions) {
      String username = item['profiles']['username'];
      String profileId = item['profile_id'];
      double doubleAmount = item['amount'] ?? 0.0;
      int amount = doubleAmount.isFinite ? doubleAmount.round() : 0;
      if (profileAmounts.containsKey(profileId)) {
        profileAmounts[profileId]!['amount'] =
            profileAmounts[profileId]!['amount'] + amount;
        expenseTotal = expenseTotal + amount;
      } else {
        profileAmounts[profileId] = {
          'username': username,
          'amount': amount,
        };
        expenseTotal = expenseTotal + amount;
      }
    }
  }

  void _calcPaymentPerPerson() {
    paymentPerPerson = profileAmounts.isNotEmpty
        ? (expenseTotal / profileAmounts.length).round()
        : 0;
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

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [];
    double totalAmount =
        profileAmounts.values.fold(0, (sum, data) => sum + data['amount']);
    String? payer, payee, payment, receive;

    Color getColorForProfile(int value) {
      // ユーザーに応じた色を返す（例: 一意の色を生成）
      if (value == 1) {
        return Colors.green;
      } else if (value == 2) {
        return Colors.blue;
      } else {
        return Colors.orange; // その他のユーザーにはオレンジ色を使う
      }
    }

    profileAmounts.forEach((profileId, data) {
      colorValue++;
      double percentage = (data['amount'] as int) / totalAmount * 100;
      sections.add(
        PieChartSectionData(
            color: getColorForProfile(colorValue),
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('清算済み'),
        ),
        body: circularIndicator,
      );
    }

    if (transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('清算済み'),
        ),
        body: Center(child: Text('データがありません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('清算済み'),
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
                            image: AssetImage('assets/icons/user_icon.png'),
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
                            image: AssetImage('assets/icons/user_icon.png'),
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
