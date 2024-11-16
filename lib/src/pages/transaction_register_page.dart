import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionRegisterPage extends StatefulWidget {
  // 画面遷移時に渡されるデータ
  final Map<String, dynamic>? transactionData;
  const TransactionRegisterPage({super.key, this.transactionData});

  @override
  TransactionRegisterPageState createState() => TransactionRegisterPageState();
}

class TransactionRegisterPageState extends State<TransactionRegisterPage> {
  // 引数に取引(明細)データがあるときは、編集画面として動作
  String? _selectedValue;
  bool _isShare = false;
  // 選択されたカテゴリー
  // TODO: 収入と支出を分けるように変更
  String selectedCategory = '食費';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<String> categories = [
    // TODO: サーバーから取得するように変更
    '食費',
    '日用品',
    '交通費',
    '交際費',
    '趣味',
    'その他',
  ];


  @override
  void initState() {
    super.initState();
    // 編集データがある場合の初期値設定
    if (widget.transactionData != null) {
      _selectedValue = widget.transactionData!['type'] ?? '支出';
      _isShare = widget.transactionData!['isShare'] ?? false;
      _dateController.text = widget.transactionData!['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      _nameController.text = widget.transactionData!['name'] ?? '';
      _amountController.text = widget.transactionData!['amount'].toString() ?? '';
      _noteController.text = widget.transactionData!['note'] ?? '';
      selectedCategory = widget.transactionData!['category'] ?? '食費';
    } else {
      // 編集データがない場合の初期設定
      _selectedValue = '支出';
      _isShare = false;
      // 本日の日付を初期値として設定
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.transactionData == null ? '収支の登録' : '収支の編集'),
      ),
      body: Center(
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
                      child: Image.asset('assets/icons/share_icon.png', width: 24),
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
                    Switch(value: _isShare,
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
                        value: '収入',
                        groupValue: _selectedValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedValue = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('支出'),
                        value: '支出',
                        groupValue: _selectedValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // 明細名
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '明細名',
                    prefixIcon: Icon(Icons.list_alt),
                  ),
                ),
                const SizedBox(height: 24),
                // 利用日
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today), // Optional: adds a calendar icon
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
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        _dateController.text = formattedDate; // Updates the TextFormField
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                // カテゴリー選択
                DropdownMenu<String>(
                  label: const Text('カテゴリ'),
                  width: 350,
                  leadingIcon: const Icon(Icons.category),
                  initialSelection: selectedCategory,
                  dropdownMenuEntries: categories.map((String category) {
                    return DropdownMenuEntry<String>(
                      value: category,
                      label: category,
                    );
                  }).toList(),
                  onSelected: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  inputDecorationTheme: const InputDecorationTheme(
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // 金額
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '金額',
                    prefixIcon: Icon(Icons.currency_yen),
                  ),
                ),
                const SizedBox(height: 24),
                // メモ
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'メモ',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  label: Text(widget.transactionData == null ? '登録' : '更新'),
                  icon: Icon(widget.transactionData == null ? Icons.edit : Icons.update),
                  iconAlignment: IconAlignment.start,
                  onPressed: () {
                    final transactionData = {
                      'type': _selectedValue,
                      'isShare': _isShare,
                      'date': _dateController.text,
                      'name': _nameController.text,
                      'amount': int.tryParse(_amountController.text),
                      'category': selectedCategory,
                      'note': _noteController.text,
                    };

                    if (widget.transactionData == null) {
                      // TODO: 新規登録処理
                      print('登録: $transactionData');
                    } else {
                      // TODO: 編集処理
                      print('編集: $transactionData');
                    }
                    Navigator.pop(context, transactionData); // データを戻す
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, double.infinity),
                    // padding: const EdgeInsets.symmetric(horizontal: 16), // ボタン内の余白調整
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
