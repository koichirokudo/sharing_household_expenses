import 'package:flutter/material.dart';

class ShareTransactionListPage extends StatelessWidget {
  const ShareTransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('共有取引一覧'),
      ),
      body:
      const Center(child: Text('共有取引一覧', style: TextStyle(fontSize: 32.0))),
    );
  }
}
