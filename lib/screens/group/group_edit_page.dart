import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/extensions/provider_ref_extensions.dart';
import 'package:sharing_household_expenses/providers/user_group_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class GroupEditPage extends ConsumerStatefulWidget {
  const GroupEditPage({super.key});

  @override
  GroupEditPageState createState() => GroupEditPageState();
}

class GroupEditPageState extends ConsumerState<GroupEditPage> {
  bool _isLoading = false;
  final _fromKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      setState(() {
        _isLoading = true;
      });
      final groupId = ref.groupId;
      if (groupId != null) {
        ref.userGroupNotifier.fetchGroup(groupId);
        final groupName = ref.userGroupState.group?.groupName;
        if (groupName != null) {
          _nameController.text = groupName;
        }
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateGroupName() async {
    final isValid = _fromKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final groupId = ref.groupId;
      if (groupId == null) {
        throw Exception('グループIDが取得できません');
      }

      final groupName = _nameController.text.trim();
      final updates = {
        'group_name': groupName,
        'slug': groupName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      ref.watch(userGroupProvider.notifier).updateGroup(groupId, updates);

      if (mounted) {
        context.showSnackBar(message: '更新しました', backgroundColor: Colors.green);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(
            message: 'プロフィール更新中にエラーが発生しました: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('グループ名変更'),
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'グループ名',
                      prefixIcon: Icon(Icons.group),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'グループ名を入力してください';
                      }
                      final isValid = RegExp(
                              r'^[a-zA-Z0-9_]|[\u3040-\u309F]|\u3000|[\u30A1-\u30FC]|[\u4E00-\u9FFF]{3,24}$')
                          .hasMatch(value);
                      if (!isValid) {
                        return 'グループ名はアルファベットか文字で3~24文字以下で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                      onPressed: _isLoading ? null : _updateGroupName,
                      label: Text(_isLoading ? '更新中' : '更新'),
                      icon: const Icon(Icons.update),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(400, double.infinity),
                      )),
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
