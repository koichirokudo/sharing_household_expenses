import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/screens/settlement/settlement_detail_page.dart';
import 'package:sharing_household_expenses/services/settlement_service.dart';
import 'package:sharing_household_expenses/services/transaction_service.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';

class SettlementListPage extends ConsumerStatefulWidget {
  const SettlementListPage({super.key});

  @override
  SettlementListPageState createState() => SettlementListPageState();
}

class SettlementListPageState extends ConsumerState<SettlementListPage> {
  bool _isLoading = false;
  late DateTime _now;
  List<String> years = [];
  late TransactionService transactionService;
  late SettlementService settlementService;
  late int selectedIndex = years.length - 1;
  List<Map<String, dynamic>> settlements = [];
  List<Map<String, dynamic>> settlementItems = [];
  late Profile profile;
  late final PageController _pageController =
      PageController(initialPage: years.length - 1, viewportFraction: 1);
  double payerAmount = 0.0;
  late String _selectedDataType = 'share';

  @override
  void initState() {
    super.initState();
    transactionService = TransactionService(supabase);
    settlementService = SettlementService(supabase);
    _initializeDate();
  }

  Future<void> _initializeDate() async {
    // 現在日時を取得する
    _now = DateTime.now();
    // 現在の年から過去2年分の年を取得する
    _generateYears(_now);
    // 今年のデータを取得する
    await _fetchDataForYear(years[selectedIndex], _selectedDataType);
  }

  Future<void> _fetchDataForYear(String year, String type) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cacheData = settlementService.loadCache(years[selectedIndex], type);
      if (cacheData != null) {
        setState(() {
          settlements = cacheData;
        });
        return;
      }

      final userId = supabase.auth.currentUser!.id;
      final auth = ref.watch(authProvider);
      // TODO: ! やめたい
      profile = auth.profile!;
      final groupId = profile.groupId;

      await Future.delayed(Duration(milliseconds: 700));

      // 選択された年の清算情報一覧を取得する
      final List<Map<String, dynamic>>? data = await settlementService
          .fetchYearlyData(groupId!, convertYearToDateTime(year));

      // 共有データ
      final shareData = data?.where((item) {
        if (item['share'] == true) {
          return true;
        }
        return false;
      }).toList();

      //　個人データ
      final privateData = data?.where((item) {
        if (item['share'] == false) {
          return true;
        }
        return false;
      }).toList();

      settlementService.storeCache(year, 'share', shareData ?? []);
      settlementService.storeCache(year, 'private', privateData ?? []);

      // 初期設定は共有データ
      setState(() {
        settlements = shareData ?? [];
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

  // リフレッシュデータ
  Future<void> _refreshData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = supabase.auth.currentUser!.id;

      await Future.delayed(Duration(milliseconds: 700));

      // 選択された年の清算情報一覧を取得する
      final List<Map<String, dynamic>>? freshData =
          await settlementService.fetchYearlyData(
              profile.groupId!, convertYearToDateTime(years[selectedIndex]));

      // 共有データ
      final shareData = freshData?.where((item) {
        if (item['share'] == true) {
          return true;
        }
        return false;
      }).toList();

      //　個人データ
      final privateData = freshData?.where((item) {
        if (item['share'] == false) {
          return true;
        }
        return false;
      }).toList();

      // キャッシュに保存（データがなくても空リストを保存）
      if (freshData != null) {
        settlementService.storeCache(
            years[selectedIndex], 'share', shareData ?? []);
        settlementService.storeCache(
            years[selectedIndex], 'private', privateData ?? []);
      }

      // set transaction data
      setState(() {
        settlements =
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

  void _generateYears(DateTime now) {
    years = List.generate(2, (index) {
      final year = DateTime(now.year - index, now.month, 1);
      return DateFormat('yyyy').format(year);
    });
    years = years.reversed.toList();
  }

  void _loadCache(selectedValue) {
    final cachedData =
        settlementService.loadCache(years[selectedIndex], selectedValue);
    if (cachedData != null) {
      setState(() {
        settlements = cachedData;
      });
    }
  }

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
          SizedBox(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  setState(() {
                    _loadCache(value);
                    _selectedDataType = value!;
                  });
                },
              ),
            ]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
                // 選択された年のデータを取得する
                Future.delayed(Duration(milliseconds: 100), () {
                  _fetchDataForYear(years[selectedIndex], _selectedDataType);
                });
              },
              itemCount: years.length,
              itemBuilder: (context, index) {
                return _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        child: settlements.isEmpty
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
                                itemCount: settlements.length,
                                itemBuilder: (context, index) {
                                  final settlementItems =
                                      settlements[index]['settlement_items'];
                                  double amount = 0;
                                  String incomeTotal = '';
                                  String expenseTotal = '';
                                  for (var item in settlementItems) {
                                    if (item['role'] == 'payer') {
                                      amount = item['amount'];
                                    }
                                  }
                                  final displayAmount = convertToYenFormat(
                                      amount: amount.round());
                                  final settlementDate =
                                      settlements[index]['settlement_date'];
                                  if (_selectedDataType == 'private') {
                                    final incomeTotalAmount = settlements[index]
                                        ['income_total_amount'];
                                    final expenseTotalAmount =
                                        settlements[index]
                                            ['expense_total_amount'];
                                    incomeTotal = convertToYenFormat(
                                        amount: incomeTotalAmount.round());
                                    expenseTotal = convertToYenFormat(
                                        amount: expenseTotalAmount.round());
                                  }
                                  return InkWell(
                                    onTap: () {
                                      // タップ時の処理
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettlementDetailPage(
                                                    settlementId:
                                                        settlements[index]
                                                            ['id'],
                                                    profile: profile,
                                                    month: settlementDate,
                                                    selectedDataType:
                                                        _selectedDataType,
                                                  )));
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // 年月
                                          Text(
                                            settlementDate,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(width: 8),
                                          _selectedDataType == 'share'
                                              ? Row(
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        // ユーザー画像
                                                        Container(
                                                          width: 32,
                                                          height: 32,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  'assets/icons/user_icon.png'),
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        // ユーザー名
                                                        Text(
                                                          settlements[index][
                                                                      'settlement_items']
                                                                  [
                                                                  0]['profiles']
                                                              ['username'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 32),
                                                    // 金額
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .trending_flat_rounded,
                                                            size: 32),
                                                        Text(
                                                          displayAmount,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 32),
                                                    // カテゴリ
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        // ユーザー画像
                                                        Container(
                                                          width: 32,
                                                          height: 32,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  'assets/icons/user_icon.png'),
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        // ユーザー名
                                                        Text(
                                                          settlements[index][
                                                                      'settlement_items']
                                                                  [
                                                                  1]['profiles']
                                                              ['username'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.black,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              :
                                              // 個人データ
                                              Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.trending_up,
                                                          color: Colors.green,
                                                          size: 24,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          '収入',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.green),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          incomeTotal,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.trending_down,
                                                      color: Colors.red,
                                                      size: 24,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '支出',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.red),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          expenseTotal,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                      );
              },
            ),
          ),
        ]));
  }
}
