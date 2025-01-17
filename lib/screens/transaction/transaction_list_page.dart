import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/constants/transaction_type.dart';
import 'package:sharing_household_expenses/extensions/provider_ref_extensions.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_detail_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../models/profile.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../settlement/settlement_page.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends ConsumerState<TransactionListPage> {
  bool _isSettlementLoading = false;
  bool _isSettlement = false;
  bool _invalidGroupCount = false;
  List<String> months = [];
  List<Transaction> transactions = [];
  Map<String, dynamic> response = {};
  late Profile profile;
  late int selectedIndex = 1;
  late final PageController _pageController;
  final List<bool> _selectedType = <bool>[true, false];
  String sharedPrivateType = 'shared';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      await ref.authNotifier.fetchProfile();
      profile = ref.authState.profile!;
      final groupId = ref.authState.profile?.groupId;
      final profileId = ref.authState.profile?.id;
      // トランザクションデータを取得
      if (groupId != null && profileId != null) {
        await ref.transactionNotifier.fetchMonthlyTransactions(
          groupId,
          profileId,
          DateTime.now(),
        );
        ref.transactionNotifier.calculateCurrentTotals();
        ref.transactionNotifier.generateMonths();
      }

      // 状態の更新
      setState(() {
        months = ref.transactionState.months;
        selectedIndex = months.isNotEmpty ? months.length - 1 : 0;
        _pageController = PageController(
          initialPage: selectedIndex,
          viewportFraction: 1,
        );
      });

      // 清算状態の確認
      response = await _checkSettlement();
      setState(() {
        _isSettlement = response['isSettlement'] == true;
        _invalidGroupCount = response['invalidGroupCount'] == true;
      });
    } catch (error, stackTrace) {
      if (mounted) {
        print('Error initializing data: $error');
        print('Stack trace: $stackTrace');
        context.showSnackBarError(message: 'データの初期化中にエラーが発生しました: $error');
      }
    }
  }

  Future<Map<String, dynamic>> _checkSettlement() async {
    setState(() {
      _isSettlementLoading = true;
    });
    try {
      final response = await ref.settlementNotifier.checkSettlement(
        sharedPrivateType == 'shared' ? 'shared' : 'private',
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
    return {};
  }

  Widget _buildMonthSelector() {
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
        transactionState.sharedCurrentTotals[TransactionType.income]?.round();
    final sharedExpenseTotalAmounts =
        transactionState.sharedCurrentTotals[TransactionType.expense]?.round();
    final privateIncomeTotalAmounts =
        transactionState.privateCurrentTotals[TransactionType.income]?.round();
    final privateExpenseTotalAmounts =
        transactionState.privateCurrentTotals[TransactionType.expense]?.round();

    final incomeTotal = convertToYenFormat(
      amount: int.parse(
        sharedPrivateType == 'shared'
            ? sharedIncomeTotalAmounts.toString()
            : privateIncomeTotalAmounts.toString(),
      ),
    );
    final expenseTotal = convertToYenFormat(
      amount: int.parse(
        sharedPrivateType == 'shared'
            ? sharedExpenseTotalAmounts.toString()
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
                fontSize: 20,
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
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return ToggleButtons(
      onPressed: (int index) async {
        setState(() {
          for (int i = 0; i < _selectedType.length; i++) {
            _selectedType[i] = i == index;
          }

          if (index == 0) {
            sharedPrivateType = 'shared';
          } else {
            sharedPrivateType = 'private';
          }
        });
        // 清算済みかをチェックする
        _isSettlement = false;
        _invalidGroupCount = false;
        response = await _checkSettlement();
        if (response['isSettlement'] == true) {
          _isSettlement = true;
        }
        if (response['invalidGroupCount'] == true) {
          _invalidGroupCount = true;
        }
      },
      borderRadius: const BorderRadius.all(
        Radius.circular(8),
      ),
      constraints: const BoxConstraints(
        minHeight: 40.0,
        minWidth: 80.0,
      ),
      isSelected: _selectedType,
      children: [
        Text('共有'),
        Text('個人'),
      ],
    );
  }

  Widget _buildSettlementButton() {
    if (_isSettlementLoading == true) {
      return ElevatedButton.icon(
        onPressed: null,
        label: Text('確認中...'),
        icon: const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isSettlement || _invalidGroupCount || transactions.isEmpty
          ? null
          : () async {
              final response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettlementPage(
                    month: months[selectedIndex],
                    transactions: transactions,
                    profile: profile,
                    isSettlement: false,
                    selectedDataType: sharedPrivateType,
                  ),
                ),
              );

              if (response == true) {
                final profileId = ref.profileId;
                final groupId = ref.groupId;
                if (profileId != null && groupId != null) {
                  ref.invalidate(transactionProvider);
                  await ref
                      .watch(transactionProvider.notifier)
                      .fetchMonthlyTransactions(
                        groupId,
                        profileId,
                        convertMonthToDateTime(months[selectedIndex]),
                      );
                }
                setState(() {
                  _isSettlement = true;
                });
              }
            },
      label: Text(_isSettlement ? '清算済み' : '清算する'),
      icon: const Icon(Icons.check_circle),
      iconAlignment: IconAlignment.start,
    );
  }

  Widget _buildNotFoundData() {
    return ListView(
      // 常にスクロール可能にすることで、データが無い場合でもリフレッシュ操作を可能にする
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
        final profileId = ref.profileId;
        final groupId = ref.groupId;
        if (profileId != null && groupId != null) {
          ref.invalidate(transactionProvider);
          await ref
              .watch(transactionProvider.notifier)
              .fetchMonthlyTransactions(
                groupId,
                profileId,
                convertMonthToDateTime(months[selectedIndex]),
              );
          ref.transactionNotifier.calculateCurrentTotals();
        }
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
                    if (response == true) {
                      final profileId = ref.profileId;
                      final groupId = ref.groupId;
                      if (profileId != null && groupId != null) {
                        await ref
                            .watch(transactionProvider.notifier)
                            .fetchMonthlyTransactions(
                              groupId,
                              profileId,
                              convertMonthToDateTime(months[selectedIndex]),
                            );
                        ref.transactionNotifier.calculateCurrentTotals();
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
                                if (transactions[index].name != '') ...[
                                  Text(
                                    '${transactions[index].name} -',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  '${transactions[index].profile?.username}',
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
                                  transactions[index].category!.name,
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
    final transactionState = ref.transactionState;
    final profileId = ref.profileId;
    final groupId = ref.groupId;
    final isLoading = transactionState.isLoading;

    transactions = sharedPrivateType == 'shared'
        ? transactionState.sharedTransactions
        : transactionState.privateTransactions;

    if (months.isEmpty || groupId == null || profileId == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('明細一覧'),
        ),
        body: circularIndicator,
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
                Future.delayed(Duration(milliseconds: 100), () async {
                  await ref.transactionNotifier.fetchMonthlyTransactions(
                    groupId,
                    profileId,
                    convertMonthToDateTime(months[selectedIndex]),
                  );
                  ref.transactionNotifier.calculateCurrentTotals();
                });
              },
              itemCount: months.length,
              itemBuilder: (context, index) {
                return isLoading
                    ? circularIndicator
                    : Column(
                        children: [
                          _buildDisplayTotalAmounts(),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildToggleButtons(),
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
