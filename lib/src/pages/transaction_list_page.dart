import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/src/pages/transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends State<TransactionListPage> {
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
      '共有しない',
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
        title: const Text('明細一覧'),
      ),
      body: Center(
        // 年月の選択
        child: Column(
          children: [
            Container(
              // 広告枠 無料会員の場合のみ表示
              height: 80,
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0x002a2a2a),
              height: 80,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                // スワイプで一つずつのみ移動可能にする
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                itemCount: months.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      if (index != selectedIndex) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Center(
                      child: Text(
                        months[index],
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 18,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.lightBlue : Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 明細一覧
            Expanded(
              child: Card(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final amount = int.parse(transactions[index][5]);
                        final formattedAmount =
                            NumberFormat('#,###').format(amount);
                        final displayAmount = '¥$formattedAmount';

                        return InkWell(
                          onTap: () {
                            // TODO: 明細画面に遷移
                            // タップ時の処理
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TransactionDetailPage(
                                        transaction: transactions[index])));
                          },
                          child: Container(
                            // 取引一覧
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0x00FFE7D4),
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
                                    // 取引名
                                    Text(
                                      transactions[index][0],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // 取引日
                                        Text(
                                          transactions[index][1],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 8),
                                        // 収支
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
                                              // fontWeight: FontWeight.bold,
                                              color:
                                                  transactions[index][3] == '収入'
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // カテゴリ
                                        Text(
                                          transactions[index][2],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 共有設定
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/icons/share_icon.png',
                                              width: 16,
                                              height: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              transactions[index][4],
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 金額
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      })),
            ),
          ],
        ),
      ),
    );
  }
}
