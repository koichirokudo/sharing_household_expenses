import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionRegisterPage extends StatefulWidget {
  // 画面遷移時に渡されるデータ
  final Map<String, dynamic>? transactionData;
  const TransactionRegisterPage({super.key, this.transactionData});

  @override
  TransactionRegisterPageState createState() => TransactionRegisterPageState();
}

class TransactionRegisterPageState extends State<TransactionRegisterPage> {
  // 引数に取引(明細)データがあるときは、編集画面として動作
  String? _selectedValue = 'expense';
  List<Map<String, dynamic>> allCategories = [];
  List<Map<String, dynamic>> filteredCategories = [];

  bool _isShare = false;
  bool _isLoading = false;
  var profile;
  int? _id;

  final _formKey = GlobalKey<FormState>();
  // 選択されたカテゴリー
  String selectedCategory = '4001';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Future<List<Map<String, dynamic>>?> _getCategories() async {
    try {
      // Supabaseからデータを取得
      final data = await supabase.from('categories').select('*');

      // 型キャスト
      final List<Map<String, dynamic>> categories =
          data.cast<Map<String, dynamic>>();

      // データが空の場合の処理
      if (categories.isEmpty) {
        if (mounted) {
          context.showSnackBarError(message: 'カテゴリーが見つかりません');
        }
        return [];
      }

      return categories;
    } on AuthException catch (error) {
      // 認証エラーをキャッチ
      if (mounted) {
        context.showSnackBarError(message: error.message);
      }
    } catch (error) {
      // その他のエラーをキャッチ
      if (mounted) {
        print('Error fetching categories: $error');
        context.showSnackBarError(message: unexpectedErrorMessage);
      }
    }

    return null; // エラー時にnullを返す
  }

  Future<void> _loadCategories() async {
    final fetchedCategories = await _getCategories();
    if (fetchedCategories != null) {
      setState(() {
        allCategories = fetchedCategories;
        return _filterCategories();
      });
    }
  }

  void _filterCategories() {
    setState(() {
      // ラジオボタンの状態によって表示するカテゴリーを切り替える
      filteredCategories = allCategories.where((categories) {
        if (_selectedValue == 'income') {
          return categories['type'] == 'income';
        } else {
          return categories['type'] == 'expense';
        }
      }).toList();

      // filteredCategories に `selectedCategory` が存在しない場合の処理
      if (!filteredCategories
          .any((category) => category['id'].toString() == selectedCategory)) {
        selectedCategory = (filteredCategories.isNotEmpty
            ? filteredCategories.first['id'].toString()
            : null)!;
      }
    });
  }

  Future<Map<String, dynamic>?> _getProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final user = supabase.auth.currentUser;
      if (user == null) {
        return null;
      }
      final data = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      return data;
    } on AuthException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: error.message);
      }
    } catch (error, stackTrace) {
      debugPrint('Unexpected error: $error\n$stackTrace');
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
    return null;
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

      final data = await supabase.from('transactions').upsert({
        'profile_id': supabase.auth.currentUser!.id,
        'group_id': profile['group_id'],
        'category_id': int.tryParse(selectedCategory),
        'amount': int.tryParse(_amountController.text.trim()),
        'share': _isShare,
        'type': _selectedValue,
        'date': _dateController.text.trim(),
        'name': _nameController.text.trim(),
        'note': _noteController.text.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).select();

      if (mounted) {
        context.showSnackBar(message: '登録しました', backgroundColor: Colors.green);
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

  Future<void> _initializeData() async {
    final fetchedProfile = await _getProfile();
    if (fetchedProfile != null) {
      setState(() {
        profile = fetchedProfile;
      });
    }
    await _loadCategories();
    // 編集データがある場合の初期値設定
    if (widget.transactionData != null) {
      _id = widget.transactionData!['id'];
      _selectedValue = widget.transactionData!['type'] ?? 'expense';
      _isShare = widget.transactionData!['isShare'] ?? false;
      _dateController.text = widget.transactionData!['date'] ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      _nameController.text = widget.transactionData!['name'] ?? '';
      _amountController.text =
          widget.transactionData!['amount'].toString() ?? '';
      _noteController.text = widget.transactionData!['note'] ?? '';
      selectedCategory = widget.transactionData!['category'] ?? '4001';
    } else {
      // 編集データがない場合の初期設定
      _selectedValue = 'expense';
      _isShare = false;
      // 本日の日付を初期値として設定
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.transactionData == null ? '収支の登録' : '収支の編集'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 共有設定
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Image.asset('assets/icons/share_icon.png',
                                width: 24),
                          ), // アイコンを先頭に配置
                          const Padding(
                            padding: EdgeInsets.only(left: 28.0, right: 124.0),
                            child: Text(
                              '共有する',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Switch(
                            value: _isShare,
                            onChanged: (bool value) => {
                              setState(() {
                                _isShare = value;
                              }),
                            },
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
                            child: RadioListTile<String>(
                              title: const Text('収入'),
                              value: 'income',
                              groupValue: _selectedValue,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedValue = value;
                                  _filterCategories();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('支出'),
                              value: 'expense',
                              groupValue: _selectedValue,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedValue = value;
                                  _filterCategories();
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
                          if (value == null || value.isEmpty) {
                            return '明細名を入力してください';
                          }
                          if (value.length > 50) {
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
                          prefixIcon: Icon(Icons
                              .calendar_today), // Optional: adds a calendar icon
                          labelText: "利用日",
                        ),
                        readOnly: true, // Prevents manual input
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
                                DateFormat('yyyy-MM-dd').format(pickedDate);
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
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'カテゴリ',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: filteredCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'].toString(),
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
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
                      ),
                      const SizedBox(height: 24),
                      // メモ
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'メモ',
                          prefixIcon: Icon(Icons.note),
                        ),
                        validator: (value) {
                          if (value != null && value.length > 100) {
                            return 'メモは30文字以下で入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        label:
                            Text(widget.transactionData == null ? '登録' : '更新'),
                        icon: Icon(widget.transactionData == null
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
        ));
  }
}
