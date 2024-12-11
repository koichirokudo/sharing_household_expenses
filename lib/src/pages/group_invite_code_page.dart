import 'package:flutter/material.dart';

class GroupInviteCodePage extends StatefulWidget {
  const GroupInviteCodePage({super.key});

  @override
  GroupInviteCodePageState createState() => GroupInviteCodePageState();
}

class GroupInviteCodePageState extends State<GroupInviteCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('グループ招待コード入力'),
      ),
      body: Center(),
    );
  }
}
