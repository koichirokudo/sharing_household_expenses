import 'package:flutter/material.dart';

class SettlementPage extends StatelessWidget {
  const SettlementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('清算'),
      ),
      body:
      const Center(child: Text('清算', style: TextStyle(fontSize: 32.0))),
    );
  }
}
