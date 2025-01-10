import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/providers/transaction_provider.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_register_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../constants/transaction_type.dart';
import '../../models/profile.dart';
import '../../models/transaction.dart';

class TransactionDetailPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  final Profile profile;
  final bool isSettlement;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.profile,
    required this.isSettlement,
  });

  @override
  TransactionDetailPageState createState() => TransactionDetailPageState();
}

class TransactionDetailPageState extends ConsumerState<TransactionDetailPage> {
  bool isEdited = false;
  bool isEditable = false;
  late Transaction transaction;
  late Profile profile;
  late String displayAmount;
  late String transactionDate;
  late bool isSettlement;

  @override
  void initState() {
    super.initState();
    // initState 内で widget.transaction を初期化
    transaction = widget.transaction;
    profile = widget.profile;
    double amount = transaction.amount;
    displayAmount = convertToYenFormat(amount: amount.round());
    DateTime date = DateTime.parse(transaction.date.toString()).toLocal();
    transactionDate = DateFormat('yyyy/MM/dd').format(date);
    isSettlement = widget.isSettlement;
  }

  Future<void> _delete() async {
    try {
      await Future.delayed(Duration(milliseconds: 700));

      final transactionId = transaction.id;
      if (transactionId == null) {
        throw Exception('トランザクションIDがありません');
      }

      await ref
          .watch(transactionProvider.notifier)
          .deleteTransaction(transaction);

      if (mounted) {
        context.showSnackBar(message: '削除しました', backgroundColor: Colors.green);
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
  }

  Widget _buildButtons() {
    if (transaction.profileId == profile.id) {
      isEditable = true;
    } else {
      isEditable = false;
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isEditable)
            ElevatedButton(
              onPressed: () {
                if (isEdited == true) {
                  Navigator.pop(context, true);
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('戻る'),
            ),
          if (isEditable)
            ElevatedButton(
              onPressed: () async {
                final response = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionRegisterPage(
                      transaction: transaction,
                    ),
                  ),
                );

                if (response != null) {
                  setState(() {
                    isEdited = true;
                    transaction = response;
                    double amount = transaction.amount;
                    displayAmount = convertToYenFormat(
                      amount: amount.round(),
                    );
                    DateTime date = DateTime.parse(
                      transaction.date.toString(),
                    ).toLocal();
                    transactionDate = DateFormat('yyyy/MM/dd').format(date);
                  });
                }
              },
              child: const Text('編集'),
            ),
          if (isEditable)
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('明細データの削除'),
                      content: Text(
                        'データを削除すると二度と復元することができません。削除しますか？',
                      ),
                      actions: [
                        TextButton(
                          child: Text('はい'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _delete();
                          },
                        ),
                        TextButton(
                          child: Text('いいえ'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('削除'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final profile = transaction.profile;
    final subCategory = transaction.subCategory;

    if (profile == null || subCategory == null) {
      return circularIndicator;
    }

    if (state.isLoading == true) {
      return circularIndicator;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('明細'),
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                transaction.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                displayAmount,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.25),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('支払人'),
                            Text(profile.username),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.25),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('共有設定'),
                            Text(transaction.share ? '共有する' : '共有しない'),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.25),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('収支'),
                            Text(
                              transaction.type == TransactionType.income
                                  ? '収入'
                                  : '支出',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.25),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('利用日'),
                            Text(transactionDate),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.25),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('カテゴリ'),
                            Text(subCategory.name),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.25),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('メモ'),
                            Text(transaction.note ?? ''),
                          ],
                        ),
                      ),
                      if (!isSettlement) _buildButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
