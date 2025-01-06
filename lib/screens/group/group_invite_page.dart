import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/user_group_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class GroupInvitePage extends ConsumerStatefulWidget {
  const GroupInvitePage({super.key});

  @override
  GroupInvitePageState createState() => GroupInvitePageState();
}

class GroupInvitePageState extends ConsumerState<GroupInvitePage> {
  bool _isLoading = false;
  final _fromKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  String? inviteCode = '';
  String? inviteLink = '';

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
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          context.showSnackBarError(message: 'グループへの参加に失敗しました');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(
            message:
                'グループへの参加処理中にエラーが発生しました: ${e.runtimeType} - ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clipBoardCopy() async {
    final inviteCode = await _generateInviteCode();
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
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.watch(userGroupProvider.notifier).generateInviteCode();
      final state = ref.watch(userGroupProvider);
      return state.inviteCode;
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(
            message: 'グループ招待コード生成中にエラーが発生しました: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    return null;
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userGroupNotifier = ref.watch(userGroupProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('グループ招待'),
      ),
      body: _isLoading
          ? circularIndicator
          : Form(
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
                            if (inviteCode != null) {
                              final lineShareUrl =
                                  userGroupNotifier.generateLineShareUrl(
                                inviteCode,
                                inviteLink,
                              );
                              await userGroupNotifier
                                  .openDeepLink(lineShareUrl);
                            }
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
