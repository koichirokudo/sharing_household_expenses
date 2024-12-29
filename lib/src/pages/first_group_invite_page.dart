import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sharing_household_expenses/src/app.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstGroupInvitePage extends StatefulWidget {
  const FirstGroupInvitePage({super.key});

  @override
  FirstGroupInvitePageState createState() => FirstGroupInvitePageState();
}

class FirstGroupInvitePageState extends State<FirstGroupInvitePage> {
  bool _isLoading = false;
  final _inviteCodeController = TextEditingController();
  final _fromKey = GlobalKey<FormState>();

  Future<void> _submitInviteCode() async {
    final isValid = _fromKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final inviteCode = _inviteCodeController.text.trim();

    try {
      final response = await supabase.functions.invoke('join-group', body: {
        'invite_code': inviteCode,
      });
      if (response.data['success'] == true) {
        if (mounted) {
          context.showSnackBar(
              message: 'グループに参加しました', backgroundColor: Colors.green);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const App()),
              (route) => false);
        }
      } else if (response.data['success'] == false) {
        if (mounted) {
          context.showSnackBarError(message: response.data['error']);
        }
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeUserGroup() async {
    final userId = supabase.auth.currentUser!.id;
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    final randomString = getRandomString(10);
    final inviteCode = getRandomString(8);
    final groupName = 'group_$randomString';
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabase
          .from('user_groups')
          .insert({
            'group_name': groupName,
            'slug': groupName,
            'invite_code': inviteCode, // 期限切れで設定しておく
            'invite_limit': DateTime.now().toIso8601String(),
            'start_day': 1,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      if (response['id'] != null) {
        await supabase.from('profiles').update({
          'group_id': response['id'],
          'invite_status': 'accepted',
          'invited_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        if (mounted) {
          context.showSnackBar(
              message: 'グループに参加しました', backgroundColor: Colors.green);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const App()),
              (route) => false);
        }
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
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
                      onPressed: _isLoading ? null : _submitInviteCode,
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
