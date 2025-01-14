import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/providers/settlement_provider.dart';
import 'package:sharing_household_expenses/screens/settlement/settlement_detail_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../constants/role.dart';
import '../../models/profile.dart';
import '../../models/settlement.dart';
import '../../models/settlement_item.dart';

class SettlementListPage extends ConsumerStatefulWidget {
  const SettlementListPage({super.key});

  @override
  SettlementListPageState createState() => SettlementListPageState();
}

class SettlementListPageState extends ConsumerState<SettlementListPage> {
  List<String> years = [];
  List<Settlement> settlements = [];
  List<Map<String, dynamic>> settlementItems = [];
  late Profile profile;
  late int selectedIndex = 1;
  late final PageController _pageController;
  final List<bool> _selectedType = <bool>[true, false];
  String sharedPrivateType = 'shared';

  @override
  void initState() {
    super.initState();
    years = [];
    Future.microtask(() async {
      final now = DateTime.now();
      final authNotifier = ref.watch(authProvider.notifier);
      final settlementNotifier = ref.watch(settlementProvider.notifier);
      // 2年分のリストを生成
      settlementNotifier.generateYears();
      await authNotifier.fetchProfile();
      final auth = ref.watch(authProvider);
      profile = auth.profile!;
      final groupId = auth.profile?.groupId;
      final settlementState = ref.watch(settlementProvider);
      if (groupId != null) {
        await settlementNotifier.fetchYearlySettlements(groupId, now);
        setState(() {
          years = settlementState.years;
          settlements = settlementState.settlements;
          selectedIndex = years.isNotEmpty ? years.length - 1 : 0;
          _pageController = PageController(
            initialPage: selectedIndex,
            viewportFraction: 1,
          );
        });
      }
    });
  }

  Widget _buildYearSelector() {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (selectedIndex > 0)
            Expanded(
              child: Center(
                child: Text(
                  years[selectedIndex - 1],
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
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
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return ToggleButtons(
      onPressed: (int index) async {
        setState(() {
          for (int i = 0; i < _selectedType.length; i++) {
            _selectedType[i] = i == index;
          }
          sharedPrivateType = index == 0 ? 'shared' : 'private';
        });
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

  Widget _buildSettlementIsEmpty() {
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

  Widget _buildSharedSettlementList(index) {
    final settlementItems = settlements[index].settlementItems;
    SettlementItem? payer;
    SettlementItem? payee;

    if (settlementItems == null) {
      return Row(children: [Text('データがありません')]);
    }

    for (var item in settlementItems) {
      if (item.role == Role.payer) {
        payer = item;
      } else if (item.role == Role.payee) {
        payee = item;
      }
    }

    if (payer == null ||
        payee == null ||
        payer.profile == null ||
        payee.profile == null) {
      return Row(children: [Text('データがありません')]);
    }

    return Row(
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
                  image: AssetImage('assets/icons/user_icon.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // ユーザー名
            Text(
              payer.profile!.username,
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
            const Icon(Icons.trending_flat_rounded, size: 32),
            Text(
              convertToYenFormat(amount: payer.amount.round()),
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
                  image: AssetImage('assets/icons/user_icon.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // ユーザー名
            Text(
              payee.profile!.username,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivateSettlementList(index) {
    final incomeTotalAmount = settlements[index].incomeTotalAmount;
    final expenseTotalAmount = settlements[index].expenseTotalAmount;
    return Row(
      children: [
        Row(
          children: [
            const Icon(
              Icons.trending_up,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '収入',
              style: TextStyle(fontSize: 12, color: Colors.green),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Text(
              convertToYenFormat(amount: incomeTotalAmount.round()),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
              style: TextStyle(fontSize: 12, color: Colors.red),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Text(
              convertToYenFormat(amount: expenseTotalAmount.round()),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCommonSettlementList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: settlements.length,
      itemBuilder: (context, index) {
        final settlementDate = settlements[index].settlementDate;
        return InkWell(
          onTap: () {
            // タップ時の処理
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettlementDetailPage(
                  settlementId: settlements[index].id.toString(),
                  profile: profile,
                  month: settlementDate,
                  selectedDataType: sharedPrivateType,
                ),
              ),
            );
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                sharedPrivateType == 'shared'
                    ? _buildSharedSettlementList(index)
                    : _buildPrivateSettlementList(index),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settlementState = ref.watch(settlementProvider);
    final isLoading = settlementState.isLoading;
    settlements = sharedPrivateType == 'shared'
        ? settlementState.sharedSettlements
        : settlementState.privateSettlements;

    if (years.isEmpty) {
      return circularIndicator;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('清算一覧'),
      ),
      body: Column(
        children: [
          _buildYearSelector(),
          _buildToggleButtons(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
                // 選択された年のデータを取得する
                Future.delayed(Duration(milliseconds: 100), () {
                  final auth = ref.watch(authProvider);
                  final groupId = auth.profile?.groupId;
                  if (groupId != null) {
                    ref
                        .watch(settlementProvider.notifier)
                        .fetchYearlySettlements(
                          groupId,
                          convertYearToDateTime(years[selectedIndex]),
                        );
                  }
                });
              },
              itemCount: years.length,
              itemBuilder: (context, index) {
                return isLoading
                    ? circularIndicator
                    : RefreshIndicator(
                        onRefresh: () async {
                          final auth = ref.watch(authProvider);
                          final groupId = auth.profile?.groupId;
                          if (groupId != null) {
                            await ref
                                .watch(settlementProvider.notifier)
                                .fetchYearlySettlements(
                                  groupId,
                                  convertYearToDateTime(years[selectedIndex]),
                                );
                          }
                        },
                        child: settlements.isEmpty
                            ? _buildSettlementIsEmpty()
                            : _buildCommonSettlementList(),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
