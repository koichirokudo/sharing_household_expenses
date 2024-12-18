import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/services/transaction_service.dart';
import 'package:sharing_household_expenses/src/pages/transaction_detail_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends State<TransactionListPage> {
  bool _isLoading = false;
  late TransactionService transactionService;
  List<String> months = [];
  List<Map<String, dynamic>> transactions = [];
  late DateTime _currentMonth;
  late int selectedIndex = months.length - 1;
  late final PageController _pageController =
      PageController(initialPage: months.length - 1, viewportFraction: 1);
  late String _selectedFilter = 'share';

  @override
  void initState() {
    super.initState();
    transactionService = TransactionService(supabase);
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 現在の月を取得する
    _currentMonth = DateTime.now();
    // 現在の月から過去１年分の月を取得する
    _generateMonths(_currentMonth);
    // 今月のデータを取得する
    _fetchDataForMonth(
        DateFormat('yyyy/MM').format(_currentMonth), _selectedFilter);
  }

  void _loadCache(selectedValue) {
    final cachedData =
        transactionService.loadCache(months[selectedIndex], selectedValue);
    if (cachedData != null) {
      setState(() {
        transactions = cachedData;
      });
    }
  }

  Future<void> _fetchDataForMonth(String month, String type) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // キャッシュチェック（有効期限を考慮）
      final cachedData = transactionService.loadCache(month, type);
      if (cachedData != null) {
        setState(() {
          transactions = cachedData;
        });
        return;
      }

      final userId = supabase.auth.currentUser!.id;
      final profile =
          await supabase.from('profiles').select().eq('id', userId).single();

      await Future.delayed(Duration(milliseconds: 700));

      // データ取得
      final List<Map<String, dynamic>>? data = await transactionService
          .fetchMonthlyData(profile['group_id'], convertToDateTime(month));

      // 自分が共有したデータ
      // 相手が共有したデータ
      final shareData = data?.where((item) {
        if (item['share'] == true) {
          return true;
        }
        return false;
      }).toList();

      final privateData = data?.where((item) {
        if (item['profile_id'] == userId) {
          return true;
        }
        return false;
      }).toList();

      // キャッシュに保存（データがなくても空リストを保存）
      transactionService.storeCache(month, 'share', shareData ?? []);
      transactionService.storeCache(month, 'private', privateData ?? []);

      // トランザクションデータを設定
      setState(() {
        transactions = shareData ?? [];
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

  // 現在の月から過去１年分の月を取得する
  void _generateMonths(currentMonth) {
    months = List.generate(12, (index) {
      final month = DateTime(currentMonth.year, currentMonth.month - index, 1);
      return DateFormat('yyyy/MM').format(month);
    });
    months = months.reversed.toList();
  }

  // 明細データから収支の合計を計算する
  String _calculateTotal(String type) {
    double total = transactions
        .where((transactions) => transactions['type'] == type)
        .fold(0.0, (sum, transaction) => sum + transaction['amount']);

    return total.ceil().toString();
  }

  // リフレッシュデータ
  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = supabase.auth.currentUser!.id;
      final profile =
          await supabase.from('profiles').select().eq('id', userId).single();
      // selected month

      await Future.delayed(Duration(milliseconds: 700));

      // refresh data
      final List<Map<String, dynamic>>? freshData =
          await transactionService.fetchMonthlyData(
              profile['group_id'], convertToDateTime(months[selectedIndex]));

      final shareData = freshData?.where((item) {
        if (item['share'] == true) {
          return true;
        }
        return false;
      }).toList();

      final privateData = freshData?.where((item) {
        if (item['profile_id'] == userId) {
          return true;
        }
        return false;
      }).toList();

      // キャッシュに保存（データがなくても空リストを保存）
      if (freshData != null) {
        transactionService.storeCache(
            months[selectedIndex], 'share', shareData ?? []);
        transactionService.storeCache(
            months[selectedIndex], 'private', privateData ?? []);
      }

      // set transaction data
      setState(() {
        transactions =
            _selectedFilter == 'share' ? shareData ?? [] : privateData ?? [];
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
                _fetchDataForMonth(months[selectedIndex], _selectedFilter);
              },
              itemCount: months.length,
              itemBuilder: (context, index) {
                // loading...
                if (_isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final incomeTotal = context.convertToYenFormat(
                    amount: int.parse(_calculateTotal('income')));
                final expenseTotal = context.convertToYenFormat(
                    amount: int.parse(_calculateTotal('expense')));

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
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // filter
                          Icon(Icons.filter),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedFilter,
                            items: [
                              DropdownMenuItem(
                                value: 'share',
                                child: Text('共有データ'),
                              ),
                              DropdownMenuItem(
                                value: 'private',
                                child: Text('マイデータ'),
                              ),
                            ],
                            onChanged: (value) {
                              _loadCache(value);
                              _selectedFilter = value!;
                            },
                          )
                        ],
                      ),
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
                                    padding: const EdgeInsets.all(16.0),
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
                                          transactions[index]['date'])
                                      .toLocal();
                                  final transactionDate =
                                      DateFormat('yyyy/MM/dd').format(date);

                                  return InkWell(
                                    onTap: () async {
                                      final response = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransactionDetailPage(
                                            transaction: transactions[index],
                                          ),
                                        ),
                                      );

                                      if (response == true) {
                                        String stringMonth =
                                            DateFormat('yyyy/MM')
                                                .format(_currentMonth);
                                        transactionService
                                            .clearCache(stringMonth);
                                        _fetchDataForMonth(
                                            stringMonth, _selectedFilter);
                                      }
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                      '- ${transactions[index]['profiles']['username']}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
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
