import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/screens/settlement/settlement_page.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_detail_page.dart';
import 'package:sharing_household_expenses/services/profile_service.dart';
import 'package:sharing_household_expenses/services/transaction_service.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends State<TransactionListPage> {
  bool _isLoading = false;
  bool _isSettlementLoading = false;
  bool _isSettlement = false;
  late TransactionService transactionService;
  late ProfileService profileService;
  List<String> months = [];
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> settlements = [];
  Map<String, dynamic> profile = {};
  late DateTime _currentMonth;
  late int selectedIndex = months.length - 1;
  late final PageController _pageController =
      PageController(initialPage: months.length - 1, viewportFraction: 1);
  late String _selectedDataType = 'share';

  @override
  void initState() {
    super.initState();
    transactionService = TransactionService(supabase);
    profileService = ProfileService(supabase);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    // 現在の月を取得する
    _currentMonth = DateTime.now();
    // 現在の月から過去１年分の月を取得する
    _generateMonths(_currentMonth);
    await _getProfile();
    // 今月のデータを取得する
    await _fetchDataForMonth(
        DateFormat('yyyy/MM').format(_currentMonth), _selectedDataType);
    await _checkSettlement();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      profile = await profileService.fetchProfile();
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
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

  Future<void> _checkSettlement() async {
    try {
      setState(() {
        _isSettlementLoading = true;
      });

      await Future.delayed(Duration(milliseconds: 350));

      // データ取得
      final List<Map<String, dynamic>> data = await supabase
          .from('settlements')
          .select('settlement_date')
          .eq('group_id', profile['group_id'])
          .eq('status', 'completed');

      for (var item in data) {
        if (item['settlement_date'] == months[selectedIndex]) {
          // 清算済み
          setState(() {
            _isSettlement = true;
          });
        } else {
          setState(() {
            _isSettlement = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    } finally {
      setState(() {
        _isSettlementLoading = false;
      });
    }
  }

  Future<void> _checkSelfSettlement() async {
    try {
      setState(() {
        _isSettlementLoading = true;
      });

      await Future.delayed(Duration(milliseconds: 350));

      // データ取得
      final List<Map<String, dynamic>> response = await supabase
          .from('settlements')
          .select(
              'id, settlement_date, settlement_items!inner(profile_id, role)')
          .eq('group_id', profile['group_id'])
          .eq('status', 'completed')
          .eq('settlement_items.role', 'self')
          .eq('settlement_items.profile_id', profile['id'])
          .textSearch('settlement_date', months[selectedIndex]);

      setState(() {
        _isSettlement = response.isNotEmpty;
      });
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    } finally {
      setState(() {
        _isSettlementLoading = false;
      });
    }
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

      await Future.delayed(Duration(milliseconds: 350));

      // データ取得
      final List<Map<String, dynamic>>? data = await transactionService
          .fetchMonthlyData(profile['group_id'], convertMonthToDateTime(month));

      // 自分が共有したデータ
      // 相手が共有したデータ
      final shareData = data?.where((item) {
        if (item['share'] == true) {
          return true;
        }
        return false;
      }).toList();

      // 自分が登録したかつ共有していないデータ
      final privateData = data?.where((item) {
        if (item['profile_id'] == userId && item['share'] == false) {
          return true;
        }
        return false;
      }).toList();

      // キャッシュに保存（データがなくても空リストを保存）
      transactionService.storeCache(month, 'share', shareData ?? []);
      transactionService.storeCache(month, 'private', privateData ?? []);

      // 初期設定は共有データ
      setState(() {
        transactions = shareData ?? [];
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
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

      await Future.delayed(Duration(milliseconds: 700));

      // refresh data
      final List<Map<String, dynamic>>? freshData =
          await transactionService.fetchMonthlyData(profile['group_id'],
              convertMonthToDateTime(months[selectedIndex]));

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
            _selectedDataType == 'share' ? shareData ?? [] : privateData ?? [];
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
                // selectedIndex を更新する前に処理を行う
                setState(() {
                  selectedIndex = index;
                });
                // 選択された月のデータを取得する
                Future.delayed(Duration(milliseconds: 100), () {
                  _fetchDataForMonth(months[selectedIndex], _selectedDataType);
                  _checkSettlement();
                });
              },
              itemCount: months.length,
              itemBuilder: (context, index) {
                final incomeTotal = convertToYenFormat(
                    amount: int.parse(_calculateTotal('income')));
                final expenseTotal = convertToYenFormat(
                    amount: int.parse(_calculateTotal('expense')));

                return _isLoading || _isSettlementLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // filter
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: _selectedDataType,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'share',
                                      child: Text('共有データ'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'private',
                                      child: Text('個人データ'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    _loadCache(value);
                                    _selectedDataType = value!;
                                    if (value == 'share') {
                                      // 共有データ時に清算済みかをチェックする
                                      _checkSettlement();
                                    } else {
                                      // 個人データ時に清算済みかをチェックする
                                      _checkSelfSettlement();
                                    }
                                  },
                                ),
                                ElevatedButton.icon(
                                  onPressed: _isSettlement ||
                                          transactions.isEmpty
                                      ? null
                                      : () async {
                                          if (profile.isNotEmpty) {
                                            final response =
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SettlementPage(
                                                              month: months[
                                                                  selectedIndex],
                                                              transactions:
                                                                  transactions,
                                                              profile: profile,
                                                              isSettlement:
                                                                  false,
                                                              selectedDataType:
                                                                  _selectedDataType,
                                                            )));

                                            if (response == true) {
                                              transactionService.clearCache(
                                                  months[selectedIndex]);
                                              _fetchDataForMonth(
                                                  months[selectedIndex],
                                                  _selectedDataType);
                                              setState(() {
                                                _isSettlement = true;
                                              });
                                            }
                                          }
                                        },
                                  label: Text(_isSettlement ? '清算済み' : '清算する'),
                                  icon: const Icon(Icons.check_circle),
                                  iconAlignment: IconAlignment.start,
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
                                        double amount =
                                            transactions[index]['amount'];
                                        final displayAmount =
                                            convertToYenFormat(
                                                amount: amount.round());
                                        final date = DateTime.parse(
                                                transactions[index]['date'])
                                            .toLocal();
                                        final transactionDate =
                                            DateFormat('yyyy/MM/dd')
                                                .format(date);

                                        return InkWell(
                                          onTap: () async {
                                            if (profile.isNotEmpty) {
                                              final response =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionDetailPage(
                                                    transaction:
                                                        transactions[index],
                                                    profile: profile,
                                                    isSettlement: _isSettlement,
                                                  ),
                                                ),
                                              );

                                              if (response == true) {
                                                transactionService.clearCache(
                                                    months[selectedIndex]);
                                                _fetchDataForMonth(
                                                    months[selectedIndex],
                                                    _selectedDataType);
                                              }
                                            } else {
                                              if (mounted) {
                                                context.showSnackBarError(
                                                    message:
                                                        'エラー: 画面を更新してください');
                                              }
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                          transactions[index]
                                                              ['name'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                            '- ${transactions[index]['profiles']['username']}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            )),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          transactionDate,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 4.0,
                                                            vertical: 1.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: transactions[
                                                                              index]
                                                                          [
                                                                          'type'] ==
                                                                      'income'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              width: 0.5,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                          child: Text(
                                                            transactions[index][
                                                                        'type'] ==
                                                                    'income'
                                                                ? '収入'
                                                                : '支出',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: transactions[
                                                                              index]
                                                                          [
                                                                          'type'] ==
                                                                      'income'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          transactions[index]
                                                                  ['categories']
                                                              ['name'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
