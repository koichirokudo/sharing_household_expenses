import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettlementDetailPage extends StatefulWidget {
  const SettlementDetailPage(
      {super.key, required Map<String, dynamic> settlement});

  @override
  SettlementDetailPageState createState() => SettlementDetailPageState();
}

class SettlementDetailPageState extends State<SettlementDetailPage> {
  // TODO: サーバーからデータを取得して表示する
  final List<String> months = [
    '2024/09',
    '2024/10',
    '2024/11',
    '2024/12',
  ];
  final List<List<String>> transactions = [
    [
      'ウーバーイーツ',
      '2024/11/01',
      '食費',
      '支出',
      '共有する',
      '1000',
    ],
    [
      'AMAZON.CO.JP',
      '2024/11/02',
      '日用品',
      '支出',
      '共有する',
      '2000',
    ],
    [
      'AMAZON.CO.JP',
      '2024/11/03',
      '交通費',
      '支出',
      '共有する',
      '3000',
    ],
    [
      'AMAZON.CO.JP',
      '2024/11/04',
      '交際費',
      '支出',
      '共有する',
      '4000',
    ],
    [
      'GITHUB, INC.利用国USA',
      '2024/11/05',
      '趣味',
      '支出',
      '共有する',
      '5000',
    ],
    [
      '楽天モバイル通信料',
      '2024/11/06',
      'スマホ',
      '支出',
      '共有する',
      '6000',
    ],
    [
      '西部ガス　料金　24／10',
      '2024/11/07',
      'ガス',
      '支出',
      '共有する',
      '7000',
    ],
    [
      '楽天SP 楽天ペイアプリセブンーイレブン',
      '2024/11/08',
      '食費',
      '支出',
      '共有する',
      '8000',
    ],
    [
      'AMAZON WER SERVI',
      '2024/11/09',
      '趣味',
      '支出',
      '共有する',
      '9000',
    ],
    [
      '楽天証券投信積立0．5％～',
      '2024/11/10',
      '投資',
      '支出',
      '共有する',
      '10000',
    ],
    [
      '楽天SP 吉野家 アプリ',
      '2024/11/11',
      '食費',
      '支出',
      '共有する',
      '11000',
    ],
    [
      '株式会社〇〇 11月分 給料',
      '2024/11/25',
      '給料',
      '収入',
      '共有する',
      '500000',
    ],
  ];
  int selectedIndex = 2; // デフォルトで2024/11が選択された状態
  final PageController _pageController =
      PageController(initialPage: 2, viewportFraction: 0.4);

  @override
  Widget build(BuildContext context) {
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
              height: 80,
              child: const Text(
                '2024年11月',
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
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: 0.3,
                      title: 'テスト太郎の支出',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 0.7,
                      title: 'テスト花子の支出',
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 清算確定ボタン
            Center(
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 清算確定処理
                    Navigator.pop(context);
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
                    shrinkWrap: true, // 必須: ListViewをColumn内で展開可能にする
                    physics:
                        const NeverScrollableScrollPhysics(), // 外側のスクロールビューに依存
                    padding: const EdgeInsets.all(16.0),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final amount = int.parse(transactions[index][5]);
                      final formattedAmount =
                          NumberFormat('#,###').format(amount);
                      final displayAmount = '¥$formattedAmount';

                      return InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => TransactionDetailPage(
                          //       transaction: transactions[index],
                          //     ),
                          //   ),
                          // );
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
                                  Text(
                                    transactions[index][0],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        transactions[index][1],
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
                                            color:
                                                transactions[index][3] == '収入'
                                                    ? Colors.green
                                                    : Colors.red,
                                            width: 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          transactions[index][3],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                transactions[index][3] == '収入'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        transactions[index][2],
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
