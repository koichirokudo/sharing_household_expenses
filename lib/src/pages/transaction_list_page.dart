import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/src/pages/transaction_detail_page.dart';
import 'package:sharing_household_expenses/utils/cache.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends State<TransactionListPage> {
  /* TODO: 仕様
      現在の月から過去の１年分確認ができる（1年以上経過したデータは残す）
      未来の月は表示できないようにする
      スワイプして月の画面を遷移できる
      データが取得できない場合はデータがないということを表示する
      データ取得時は、今月の分のみを取得して、一度取得したデータは、更新されない限りキャッシュを使う
      キャッシュの有効期限機能をつける
      データ更新はリストを下に引っ張って更新できるようにする？
      収入と支出の合計を表示させる
   */
  bool _isLoading = false;
  List<String> months = [];
  List<Map<String, dynamic>> transactions = [];
  late DateTime _currentMonth;
  late int selectedIndex = months.length - 1;
  late final PageController _pageController =
      PageController(initialPage: months.length - 1, viewportFraction: 1);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 現在の月を取得する
    _currentMonth = DateTime.now();
    // 現在の月から過去１年分の月を取得する
    _generateMonths(_currentMonth);
    // 今月のデータを取得する
    _fetchDataForMonth(DateFormat('yyyy/MM').format(_currentMonth));
  }

  Future<void> _fetchDataForMonth(String month) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // キャッシュチェック（有効期限を考慮）
      final cachedData = getCachedTransactions(month);
      if (cachedData != null) {
        setState(() {
          transactions = cachedData;
        });
        return;
      }

      await Future.delayed(Duration(milliseconds: 700));

      // データ取得
      final List<Map<String, dynamic>>? data =
          await _getTransactions(_convertToDateTime(month));

      // キャッシュに保存（データがなくても空リストを保存）
      cacheTransactions(month, data ?? []);

      // トランザクションデータを設定
      setState(() {
        transactions = data ?? [];
      });
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

  void cacheTransactions(String month, List<Map<String, dynamic>> data) {
    cachedData[month] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  // キャッシュの有効期限をチェック 15分
  List<Map<String, dynamic>>? getCachedTransactions(String month,
      {Duration expiry = const Duration(minutes: 15)}) {
    final cache = cachedData[month];
    if (cache != null) {
      final timestamp = cache['timestamp'] as DateTime;
      // 有効期限内の場合のみデータを返す
      if (DateTime.now().difference(timestamp) <= expiry) {
        return cache['data'] as List<Map<String, dynamic>>;
      }
    }
    return null;
  }

  // 現在の月から過去１年分の月を取得する
  void _generateMonths(currentMonth) {
    months = List.generate(12, (index) {
      final month = DateTime(currentMonth.year, currentMonth.month - index, 1);
      return DateFormat('yyyy/MM').format(month);
    });
    months = months.reversed.toList();
  }

  // String型からDateTime型に変換する
  DateTime _convertToDateTime(String monthString) {
    // DateFormat で yyyy/MM 形式を指定
    DateFormat format = DateFormat('yyyy/MM');
    return format.parse(monthString);
  }

  // 明細データから収支の合計を計算する
  String calculateTotal(String type) {
    double total = transactions
        .where((transactions) => transactions['type'] == type)
        .fold(0.0, (sum, transaction) => sum + transaction['amount']);

    return total.ceil().toString();
  }

  // 明細データを取得する
  Future<List<Map<String, dynamic>>?> _getTransactions(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month);
      final endOfMonth = DateTime(month.year, month.month + 1)
          .subtract(const Duration(seconds: 1));
      final data = await supabase
          .from('transactions')
          .select('*, categories(name)')
          .gte('date', startOfMonth.toIso8601String())
          .lt('date', endOfMonth.toIso8601String())
          .order('date', ascending: false);

      return data as List<Map<String, dynamic>>?;
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
      return null;
    }
  }

  // リフレッシュデータ
  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // selected month
      String month = months[selectedIndex];

      await Future.delayed(Duration(milliseconds: 700));

      // refresh data
      final List<Map<String, dynamic>>? freshData =
          await _getTransactions(_convertToDateTime(month));

      // update new cache data
      if (freshData != null) {
        cacheTransactions(month, freshData);
      }

      // set transaction data
      setState(() {
        transactions = freshData ?? [];
      });
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
                // 選択された月のデータを取得する
                _fetchDataForMonth(months[selectedIndex]);
              },
              itemCount: months.length,
              itemBuilder: (context, index) {
                // loading...
                if (_isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // データが無い
                // if (transactions.isEmpty) {
                //   return Center(
                //     child: Text(
                //       'データがありません。\nリストを下に引っ張って更新してください。',
                //       textAlign: TextAlign.center,
                //       style: const TextStyle(
                //           fontSize: 18, fontWeight: FontWeight.bold),
                //     ),
                //   );
                // }

                final incomeTotal = context.convertToYenFormat(
                    amount: int.parse(calculateTotal('income')));
                final expenseTotal = context.convertToYenFormat(
                    amount: int.parse(calculateTotal('expense')));

                return Column(
                  children: [
                    Row(
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
                                fontSize: 24,
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
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: transactions.isEmpty
                            ? ListView(
                                // 常にスクロール可能にすることで、データが無い場合でもリフレっ操作を可能にする
                                physics: AlwaysScrollableScrollPhysics(),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                          'データがありません。\n下に引っ張って更新してください。',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey)),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  double amount = transactions[index]['amount'];
                                  final displayAmount =
                                      context.convertToYenFormat(
                                          amount: amount.round());
                                  final date = DateTime.parse(
                                      transactions[index]['date']);
                                  final transactionDate =
                                      DateFormat('yyyy/MM/dd').format(date);

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransactionDetailPage(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                transactions[index]['name'],
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
                                                    transactionDate,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4.0,
                                                      vertical: 1.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: transactions[
                                                                        index]
                                                                    ['type'] ==
                                                                'income'
                                                            ? Colors.green
                                                            : Colors.red,
                                                        width: 0.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                    ),
                                                    child: Text(
                                                      transactions[index]
                                                                  ['type'] ==
                                                              'income'
                                                          ? '収入'
                                                          : '支出',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: transactions[
                                                                        index]
                                                                    ['type'] ==
                                                                'income'
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    transactions[index]
                                                        ['categories']['name'],
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
