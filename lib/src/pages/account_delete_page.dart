import 'package:flutter/material.dart';

class AccountDeletePage extends StatefulWidget {
  const AccountDeletePage({super.key});

  @override
  AccountDeletePageState createState() => AccountDeletePageState();
}

class AccountDeletePageState extends State<AccountDeletePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('アカウント削除'),
      ),
      body: Center(),
    );
  }
}
