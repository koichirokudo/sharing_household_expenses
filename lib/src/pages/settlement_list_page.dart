import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/src/pages/settlement_detail_page.dart';

class SettlementListPage extends StatefulWidget {
  const SettlementListPage({super.key});

  @override
  SettlementListPageState createState() => SettlementListPageState();
}

class SettlementListPageState extends State<SettlementListPage> {
  // TODO: サーバーからデータを取得して表示する
  final List<String> years = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
  ];
  final List<List<String>> settlements = [
    [
      '2024年1月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年2月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年3月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年4月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年5月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年6月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年7月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年8月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年9月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
    [
      '2024年10月',
      'テスト太郎',
      'テスト花子',
      '110000',
    ],
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
          title: const Text('清算一覧'),
        ),
        body: Column(children: [
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedIndex > 0)
                  Expanded(
                    child: Center(
                      child: Text(
                        years[selectedIndex - 1],
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      years[selectedIndex],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
                if (selectedIndex < years.length - 1)
                  Expanded(
                    child: Center(
                      child: Text(
                        years[selectedIndex + 1],
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
              itemCount: years.length,
              itemBuilder: (context, index) {
                return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: settlements.length,
                    itemBuilder: (context, index) {
                      final amount = int.parse(settlements[index][3]);
                      final formattedAmount =
                          NumberFormat('#,###').format(amount);
                      final displayAmount = '¥$formattedAmount';

                      return InkWell(
                        onTap: () {
                          // TODO: 清算画面に遷移
                          // タップ時の処理
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettlementDetailPage(
                                      settlement: settlements[index])));
                        },
                        child: Container(
                          // 清算一覧
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // 年月
                              Text(
                                settlements[index][0],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 32),
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      // ユーザー名
                                      Text(
                                        settlements[index][1],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 32),
                                  // 金額
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.trending_flat_rounded,
                                          size: 32),
                                      Text(
                                        displayAmount,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 32),
                                  // カテゴリ
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      // ユーザー名
                                      Text(
                                        settlements[index][2],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ]));
  }
}
