import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/src/pages/transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends State<TransactionListPage> {
  final List<String> months = [
    '2024/09',
    '2024/10',
    '2024/11',
    '2024/12',
    '2025/01',
    '2025/02',
    '2025/03',
    '2025/04',
    '2025/05',
    '2025/06',
    '2025/07',
    '2025/08',
    '2025/09',
    '2025/10',
    '2025/11',
    '2025/12',
    '2026/01',
  ];
  final List<List<String>> transactions = [
    ['ウーバーイーツ', '2024/11/01', '食費', '支出', '共有する', '1000'],
    ['AMAZON.CO.JP', '2024/11/02', '日用品', '支出', '共有する', '2000'],
    ['AMAZON.CO.JP', '2024/11/03', '交通費', '支出', '共有する', '3000'],
    ['AMAZON.CO.JP', '2024/11/04', '交際費', '支出', '共有する', '4000'],
    ['GITHUB, INC.利用国USA', '2024/11/05', '趣味', '支出', '共有する', '5000'],
    ['楽天モバイル通信料', '2024/11/06', 'スマホ', '支出', '共有する', '6000'],
    ['西部ガス　料金　24／10', '2024/11/07', 'ガス', '支出', '共有する', '7000'],
    ['楽天SP 楽天ペイアプリセブンーイレブン', '2024/11/08', '食費', '支出', '共有する', '8000'],
    ['AMAZON WER SERVI', '2024/11/09', '趣味', '支出', '共有する', '9000'],
    ['楽天証券投信積立0．5％～', '2024/11/10', '投資', '支出', '共有する', '10000'],
    ['楽天SP 吉野家 アプリ', '2024/11/11', '食費', '支出', '共有する', '11000'],
    ['株式会社〇〇 11月分 給料', '2024/11/25', '給料', '収入', '共有しない', '500000'],
  ];
  int selectedIndex = 2; // デフォルトで2024/11が選択された状態
  final PageController _pageController =
      PageController(initialPage: 2, viewportFraction: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('明細一覧'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedIndex > 0)
                  Expanded(
                    child: Center(
                      child: Text(
                        months[selectedIndex - 1],
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      months[selectedIndex],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
                if (selectedIndex < months.length - 1)
                  Expanded(
                    child: Center(
                      child: Text(
                        months[selectedIndex + 1],
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              itemCount: months.length,
              itemBuilder: (context, index) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final amount = int.parse(transactions[index][5]);
                    final formattedAmount =
                        NumberFormat('#,###').format(amount);
                    final displayAmount = '¥$formattedAmount';

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailPage(
                              transaction: transactions[index],
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
                                  children: [
                                    Text(
                                      transactions[index][1],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                        vertical: 1.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: transactions[index][3] == '収入'
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
                                          color: transactions[index][3] == '収入'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
