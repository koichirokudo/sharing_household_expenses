import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupInvitePage extends StatefulWidget {
  const GroupInvitePage({super.key});

  @override
  GroupInvitePageState createState() => GroupInvitePageState();
}

class GroupInvitePageState extends State<GroupInvitePage> {
  bool _isLoading = false;
  final _fromKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  String? inviteCode = '';
  String? inviteLink = '';

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
      final response = await supabase.functions.invoke("join-group", body: {
        'invite_code': inviteCode,
      });
      if (response.data['success'] == true) {
        if (mounted) {
          context.showSnackBar(
              message: 'グループに参加しました', backgroundColor: Colors.green);
          Navigator.pop(context);
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

  Future<void> _clipBoardCopy() async {
    String? inviteCode = await _generateInviteCode();
    if (inviteCode != null) {
      final data = ClipboardData(text: inviteCode);
      await Clipboard.setData(data);
      if (mounted) {
        context.showSnackBar(
            message: 'グループ招待コードをコピーしました。グループに参加したい方へ共有してください。',
            backgroundColor: Colors.green);
      }
    }
  }

  Future<String?> _generateInviteCode() async {
    final userId = supabase.auth.currentUser!.id;
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

    final duration =
        DateTime.now().add(Duration(minutes: 20)).toIso8601String();

    try {
      final inviteCode = getRandomString(8);
      final profile =
          await supabase.from('profiles').select().eq('id', userId).single();
      await supabase.from('user_groups').update({
        'invite_code': inviteCode,
        'invite_limit': duration,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', profile['group_id']);
      return inviteCode;
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
      }
    }

    return null;
  }

  // LINE用のDeep Link生成
  String generateLineShareUrl(String code, String link) {
    final message =
        'シェア家計簿のグループ招待です。招待コードを使ってグループに参加してください。\n招待コード: $code\nこちらのリンクから参加: $link';
    return 'https://line.me/R/share?text=${Uri.encodeComponent(message)}';
  }

  // Deep Linkを開く
  Future<void> openLink(String url) async {
    // URLをUri型に変換
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // 外部アプリでURLを開く
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
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
        title: const Text('グループ招待'),
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
                  Text('グループに参加する場合は、招待コードを入力してください。'),
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
                      'グループに招待する場合は、招待コードをコピーして参加希望者に共有してください。コードの有効期間はコピーしてから20分間です。'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _clipBoardCopy,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(400, double.infinity),
                      minimumSize: Size(400, 40),
                    ),
                    child: const Text('グループ招待コードをコピーする'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final inviteCode = await _generateInviteCode();
                      String inviteLink = '';
                      if (Platform.isAndroid) {
                        //todo Google play store url
                        inviteLink = 'google play store url';
                      } else if (Platform.isIOS) {
                        //todo apple store url
                        inviteLink = 'apple store url';
                      }
                      final lineShareUrl = generateLineShareUrl(
                          inviteCode as String, inviteLink);
                      openLink(lineShareUrl);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(400, double.infinity),
                      minimumSize: Size(400, 40),
                    ),
                    child: const Text('LINEでグループ招待コードを送信する'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
