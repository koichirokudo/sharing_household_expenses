import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/constants/settlement_visibility.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_detail_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settlement_provider.dart';
import '../../providers/transaction_provider.dart';
import '../settlement/settlement_page.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends ConsumerState<TransactionListPage> {
  bool _isLoading = false;
  bool _isSettlementLoading = false;
  bool _isSettlement = false;
  List<String> months = [];
  List<Transaction> transactions = [];
  List<Map<String, dynamic>> settlements = [];
  Map<String, dynamic> profile = {};
  late int selectedIndex = 1;
  late final PageController _pageController;
  late String _selectedDataType = 'shared';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      setState(() {
        _isLoading = true;
      });
      final authNotifier = ref.watch(authProvider.notifier);
      await authNotifier.fetchProfile();
      final auth = ref.watch(authProvider);
      final transactionNotifier = ref.watch(transactionProvider.notifier);
      final transactionState = ref.watch(transactionProvider);
      final currentMonth = DateTime.now();
      if (auth.profile != null) {
        await transactionNotifier.fetchMonthlyTransactions(
          auth.profile?['group_id'],
          currentMonth,
        );
        setState(() {
          months = transactionState.months;
          selectedIndex = months.isNotEmpty ? months.length - 1 : 0;
          _pageController = PageController(
            initialPage: selectedIndex,
            viewportFraction: 1,
          );
        });
        await _checkSettlement();
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<bool> _checkSettlement() async {
    try {
      setState(() {
        _isSettlementLoading = true;
      });

      final auth = ref.watch(authProvider);
      final profile = auth.profile;

      if (profile == null) {
        throw Exception('Profile is not available');
      }

      final response =
          await ref.watch(settlementProvider.notifier).checkSettlement(
                _selectedDataType == 'shared'
                    ? SettlementVisibility.shared.toString()
                    : SettlementVisibility.private.toString(),
                months[selectedIndex],
              );

      return response;
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    } finally {
      setState(() {
        _isSettlementLoading = false;
      });
    }
    return false;
  }

  Widget _buildMonthSelector() {
    if (months.isEmpty) {
      return Center(
        child: Text(
          '月データがありません',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (selectedIndex > 0)
            Expanded(
              child: Center(
                child: Text(
                  months[selectedIndex - 1],
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
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
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisplayTotalAmounts() {
    final transactionState = ref.watch(transactionProvider);
    final sharedIncomeTotalAmounts =
        transactionState.sharedTotalAmounts[TransactionType.income]?.round();
    final sharedExpenseTotalAmounts =
        transactionState.sharedTotalAmounts[TransactionType.expense]?.round();
    final privateIncomeTotalAmounts =
        transactionState.privateTotalAmounts[TransactionType.income]?.round();
    final privateExpenseTotalAmounts =
        transactionState.privateTotalAmounts[TransactionType.expense]?.round();

    final incomeTotal = convertToYenFormat(
      amount: int.parse(
        _selectedDataType == 'shared'
            ? sharedIncomeTotalAmounts.toString()
            : sharedExpenseTotalAmounts.toString(),
      ),
    );
    final expenseTotal = convertToYenFormat(
      amount: int.parse(
        _selectedDataType == 'shared'
            ? privateIncomeTotalAmounts.toString()
            : privateExpenseTotalAmounts.toString(),
      ),
    );
    return Row(
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
    );
  }

  Widget _buildSelectedType() {
    return DropdownButton<String>(
      value: _selectedDataType,
      items: [
        DropdownMenuItem(
          value: 'shared',
          child: Text('共有データ'),
        ),
        DropdownMenuItem(
          value: 'private',
          child: Text('個人データ'),
        ),
      ],
      onChanged: (value) {
        _selectedDataType = value!;
        // 清算済みかをチェックする
        _checkSettlement();
      },
    );
  }

  Widget _buildSettlementButton() {
    return ElevatedButton.icon(
      onPressed: _isSettlement || transactions.isEmpty
          ? null
          : () async {
              if (profile.isNotEmpty) {
                final response = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettlementPage(
                      month: months[selectedIndex],
                      transactions: transactions,
                      profile: profile,
                      isSettlement: false,
                      selectedDataType: _selectedDataType,
                    ),
                  ),
                );
              }
            },
      label: Text(_isSettlement ? '清算済み' : '清算する'),
      icon: const Icon(Icons.check_circle),
      iconAlignment: IconAlignment.start,
    );
  }

  Widget _buildNotFoundData() {
    return ListView(
      // 常にスクロール可能にすることで、データが無い場合でもリフレっ操作を可能にする
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'データがありません。\n下に引っ張って更新してください。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator() {
    return RefreshIndicator(
      onRefresh: () async {
        final auth = ref.watch(authProvider);
        await ref.watch(transactionProvider.notifier).fetchMonthlyTransactions(
              auth.profile?['group_id'],
              DateTime.parse(months[selectedIndex]),
            );
      },
      child: transactions.isEmpty
          ? _buildNotFoundData()
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                double amount = transactions[index].amount;
                final displayAmount = convertToYenFormat(
                  amount: amount.round(),
                );
                final date = DateTime.parse(transactions[index].date.toString())
                    .toLocal();
                final transactionDate = DateFormat('yyyy/MM/dd').format(date);

                return InkWell(
                  onTap: () async {
                    if (profile.isNotEmpty) {
                      final response = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailPage(
                            transaction: transactions[index],
                            profile: profile,
                            isSettlement: _isSettlement,
                          ),
                        ),
                      );
                    } else {
                      if (mounted) {
                        context.showSnackBarError(message: 'エラー: 画面を更新してください');
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  transactions[index].name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '- ${transactions[index].profile?.username}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
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
                                      color: transactions[index].type ==
                                              TransactionType.income
                                          ? Colors.green
                                          : Colors.red,
                                      width: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    transactions[index].type ==
                                            TransactionType.income
                                        ? '収入'
                                        : '支出',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: transactions[index].type ==
                                              TransactionType.income
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  transactions[index].subCategory!.name,
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
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionNotifier = ref.watch(transactionProvider.notifier);
    final transactionState = ref.watch(transactionProvider);
    transactions = _selectedDataType == 'shared'
        ? transactionState.sharedTransactions
        : transactionState.privateTransactions;

    if (months.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('明細一覧'),
        ),
        body: Center(
          child: Text(
            'データがありません。',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('明細一覧'),
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                // selectedIndex を更新する前に処理を行う
                setState(() {
                  selectedIndex = index;
                });
                // 選択された月のデータを取得する
                transactionNotifier.fetchMonthlyTransactions(
                  profile['group_id'],
                  DateTime.parse(months[selectedIndex]),
                );
              },
              itemCount: months.length,
              itemBuilder: (context, index) {
                return _isLoading || _isSettlementLoading
                    ? circularIndicator
                    : Column(
                        children: [
                          _buildDisplayTotalAmounts(),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // filter
                                const SizedBox(width: 8),
                                _buildSelectedType(),
                                _buildSettlementButton(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildIndicator(),
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
