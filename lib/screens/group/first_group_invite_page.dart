import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/app.dart';
import 'package:sharing_household_expenses/providers/user_group_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class FirstGroupInvitePage extends ConsumerStatefulWidget {
  const FirstGroupInvitePage({super.key});

  @override
  FirstGroupInvitePageState createState() => FirstGroupInvitePageState();
}

class FirstGroupInvitePageState extends ConsumerState<FirstGroupInvitePage> {
  bool _isLoading = false;
  final _fromKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();

  Future<void> _joinGroup() async {
    final isValid = _fromKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final inviteCode = _inviteCodeController.text.trim();

    try {
      final response =
          await ref.watch(userGroupProvider.notifier).joinGroup(inviteCode);
      if (response == true) {
        if (mounted) {
          context.showSnackBar(
              message: 'グループに参加しました', backgroundColor: Colors.green);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const App()),
              (route) => false);
        }
      } else {
        if (mounted) {
          context.showSnackBarError(message: 'グループへの参加に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(
          message: 'グループへの参加処理中にエラーが発生しました: ${e.runtimeType} - ${e.toString()}',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeUserGroup() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ref.watch(userGroupProvider.notifier).makeGroup();
      if (response == true) {
        if (mounted) {
          context.showSnackBar(
              message: 'グループに参加しました', backgroundColor: Colors.green);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const App()),
              (route) => false);
        }
      } else {
        if (mounted) {
          context.showSnackBarError(message: 'グループへの参加に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(
          message: 'グループへの参加処理中にエラーが発生しました: ${e.runtimeType} - ${e.toString()}',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('初回設定:グループへの参加'),
      ),
      body: Form(
        key: _fromKey,
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text('招待コードをお持ちの方'),
                  TextFormField(
                    controller: _inviteCodeController,
                    decoration: InputDecoration(
                      labelText: '招待コードを入力',
                      prefixIcon: const Icon(Icons.group_add),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '招待コードが入力されていません';
                      }
                      if (value.length != 8) {
                        return '招待コードは8桁のコードです';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                      onPressed: _isLoading ? null : _joinGroup,
                      label: Text(_isLoading ? '' : '招待されたグループに参加する'),
                      icon: _isLoading
                          ? CircularProgressIndicator()
                          : Icon(Icons.group_add),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(400, double.infinity),
                      )),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                      '新規でグループを作成する 一人でアプリを利用したり、これから他のユーザーに招待コードを送る方はこちらのボタンをクリックしてください。'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _makeUserGroup,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(400, double.infinity),
                      minimumSize: Size(400, 40),
                    ),
                    child: Text('グループを新規作成する'),
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
