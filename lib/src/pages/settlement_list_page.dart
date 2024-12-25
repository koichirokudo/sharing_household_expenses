import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/services/settlement_service.dart';
import 'package:sharing_household_expenses/services/transaction_service.dart';
import 'package:sharing_household_expenses/src/pages/settlement_detail_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettlementListPage extends StatefulWidget {
  const SettlementListPage({super.key});

  @override
  SettlementListPageState createState() => SettlementListPageState();
}

class SettlementListPageState extends State<SettlementListPage> {
  bool _isLoading = false;
  late DateTime _now;
  List<String> years = [];
  late TransactionService transactionService;
  late SettlementService settlementService;
  late int selectedIndex = years.length - 1;
  List<Map<String, dynamic>> settlements = [];
  Map<String, dynamic> profile = {};
  late final PageController _pageController =
      PageController(initialPage: years.length - 1, viewportFraction: 1);

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
    _fetchDataForYear(years[selectedIndex]);
  }

  Future<void> _fetchDataForYear(String year) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cacheData = settlementService.loadCache(years[selectedIndex]);
      if (cacheData != null) {
        setState(() {
          settlements = cacheData;
        });
        return;
      }

      final userId = supabase.auth.currentUser!.id;
      profile =
          await supabase.from('profiles').select().eq('id', userId).single();

      await Future.delayed(Duration(milliseconds: 700));

      // 選択された年の清算情報一覧を取得する
      final List<Map<String, dynamic>>? data = await settlementService
          .fetchYearlyData(profile['group_id'], convertYearToDateTime(year));

      settlementService.storeCache(year, data ?? []);
      setState(() {
        settlements = data ?? [];
      });
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

  void _generateYears(DateTime now) {
    years = List.generate(2, (index) {
      final year = DateTime(now.year - index, now.month, 1);
      return DateFormat('yyyy').format(year);
    });
    years = years.reversed.toList();
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
                      double amount = settlements[index]['total_amount'];
                      final displayAmount =
                          context.convertToYenFormat(amount: amount.round());
                      final settlementDate = DateFormat('yyyy/MM').format(
                          DateTime.parse(
                              settlements[index]['settlement_date']));
                      return InkWell(
                        onTap: () {
                          // TODO: 清算画面に遷移
                          // タップ時の処理
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettlementDetailPage(
                                        settlementId: settlements[index]['id'],
                                        profile: profile,
                                        month: settlementDate,
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
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                        settlements[index]['settlement_items']
                                            [0]['profiles']['username'],
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
                                        settlements[index]['settlement_items']
                                            [1]['profiles']['username'],
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
