import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/models/transaction.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/providers/settlement_provider.dart';
import 'package:sharing_household_expenses/providers/transaction_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/transaction_type.dart';
import '../../providers/category_provider.dart';

class TransactionRegisterPage extends ConsumerStatefulWidget {
  // 画面遷移時に渡されるデータ
  final Transaction? transaction;

  const TransactionRegisterPage({super.key, this.transaction});

  @override
  TransactionRegisterPageState createState() => TransactionRegisterPageState();
}

class TransactionRegisterPageState
    extends ConsumerState<TransactionRegisterPage> {
  bool _isLoading = false;
  int? _id;
  bool _share = true;
  String _selectedType = 'expense';
  String? _selectedCategory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      setState(() {
        _isLoading = true;
      });
      final categoryNotifier = ref.watch(categoryProvider.notifier);
      categoryNotifier.groupByType();
      _initializeData();
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final transaction = widget.transaction;
    if (transaction != null) {
      // 編集データがある場合の初期値設定
      _id = transaction.id;
      _selectedType =
          transaction.type == TransactionType.income ? 'income' : 'expense';
      _selectedCategory = transaction.category!.id.toString();
      _share = transaction.share;
      _dateController.text = DateFormat('yyyy/MM/dd').format(DateTime.parse(
        transaction.date.toString(),
      ).toLocal());
      _nameController.text = transaction.name ?? '';
      _amountController.text = transaction.amount.round().toString();
    } else {
      // 編集データがない場合の初期設定
      _selectedType = 'expense';
      _selectedCategory = '4001';
      _share = true;
      _dateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());
    }
  }

  Future<void> _register() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final auth = ref.watch(authProvider);
      final profileId = auth.profile?.id;
      final groupId = auth.profile?.groupId;

      final response =
          await _checkSettlement(_dateController.text.substring(0, 7));
      if (response['isSettlement'] == true) {
        // 清算済みの場合は登録することができない
        if (mounted) {
          context.showSnackBarError(message: '選択した月はすでに清算済みのため登録できません');
        }
        return;
      }

      if (_selectedCategory == null || profileId == null || groupId == null) {
        return;
      }

      final data = {
        if (_id != null) 'id': _id,
        'profile_id': profileId,
        'group_id': groupId,
        'category_id': int.tryParse(_selectedCategory!),
        'amount': int.tryParse(_amountController.text.trim()),
        'share': _share,
        'type': _selectedType == 'income' ? 'income' : 'expense',
        'date': _dateController.text.trim(),
        'name': _nameController.text.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await Future.delayed(Duration(milliseconds: 150));

      late Transaction? updatedTransaction;
      if (data['id'] != null) {
        updatedTransaction = await ref
            .watch(transactionProvider.notifier)
            .updateTransaction(data);
      } else if (data['id'] == null) {
        await ref.watch(transactionProvider.notifier).insertTransaction(data);
      }

      // 新規登録
      if (_id == null) {
        if (_formKey.currentState != null) {
          _formKey.currentState!.reset();
        }
        _dateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());
        _nameController.clear();
        _amountController.clear();
        _selectedType = 'expense';
        _share = true;
        _selectedCategory = '4001';
      } else {
        // 更新
        if (mounted) {
          Navigator.pop(context, updatedTransaction);
        }
      }

      if (mounted) {
        context.showSnackBar(
          message: _id != null ? '更新しました' : '登録しました',
          backgroundColor: Colors.green,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: error.message);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: unexpectedErrorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _checkSettlement(String month) async {
    try {
      final auth = ref.watch(authProvider);
      final profile = auth.profile;

      if (profile == null) {
        throw Exception('Profile is not available');
      }

      final response =
          await ref.watch(settlementProvider.notifier).checkSettlement(
                _share ? 'shared' : 'private',
                month,
              );

      return response;
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    List<DropdownMenuItem<String>> buildCategories() {
      final categories = _selectedType == 'income'
          ? categoryState.incomeCategories
          : categoryState.expenseCategories;

      return categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id.toString(),
          child: Text(category.name),
        );
      }).toList(); // map の結果を List に変換
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.transaction == null ? '収支の登録' : '収支の編集'),
      ),
      body: _isLoading
          ? circularIndicator
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 共有するしないの選択
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Image.asset('assets/icons/share_icon.png',
                                  width: 24),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text(
                                  '共有する',
                                  style: TextStyle(fontSize: 13),
                                ),
                                value: true,
                                groupValue: _share,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _share = true;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text(
                                  '共有しない',
                                  style: TextStyle(fontSize: 13),
                                ),
                                value: false,
                                groupValue: _share,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _share = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 収入・支出選択
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Icon(Icons.done),
                            ), // アイコンを先頭に配置
                            Expanded(
                              child: RadioListTile(
                                title: const Text('収入'),
                                value: 'income',
                                groupValue: _selectedType,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedType = 'income';
                                    _selectedCategory = '4017';
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('支出'),
                                value: 'expense',
                                groupValue: _selectedType,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedType = 'expense';
                                    _selectedCategory = '4001';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        // 明細名
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '明細名',
                            prefixIcon: Icon(Icons.list_alt),
                          ),
                          validator: (value) {
                            if (value != null && value.length > 50) {
                              return '明細名は50文字以下で入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // 利用日
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today),
                            // Optional: adds a calendar icon
                            labelText: '利用日',
                          ),
                          readOnly: true,
                          // Prevents manual input
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              locale: const Locale('ja', 'JP'),
                              barrierDismissible: true,
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('yyyy/MM/dd').format(pickedDate);
                              setState(() {
                                _dateController.text =
                                    formattedDate; // Updates the TextFormField
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '利用日を入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // カテゴリ選択
                        DropdownButtonFormField<String>(
                          value: buildCategories().any(
                                  (item) => item.value == _selectedCategory)
                              ? _selectedCategory
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'カテゴリ',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: buildCategories(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'カテゴリを選択してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // 金額
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: '金額',
                            prefixIcon: Icon(Icons.currency_yen),
                          ),
                          validator: (value) {
                            if (value != null) {
                              final isValid =
                                  RegExp(r'^\d{1,8}$').hasMatch(value);
                              if (!isValid) {
                                return '数値を入力してください（最大8桁まで）';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          label: Text(widget.transaction == null ? '登録' : '更新'),
                          icon: Icon(widget.transaction == null
                              ? Icons.edit
                              : Icons.update),
                          iconAlignment: IconAlignment.start,
                          onPressed: () {
                            _isLoading ? null : _register();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(300, double.infinity),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
