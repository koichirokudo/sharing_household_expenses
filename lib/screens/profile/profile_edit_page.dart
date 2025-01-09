import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:sharing_household_expenses/widgets/avatar.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ProfileEditPageState createState() => ProfileEditPageState();
}

class ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  bool _isLoading = false;
  final _fromKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _usernameController.text = auth.profile?.username ?? '';
  }

  Future<void> _updateProfile() async {
    final isValid = _fromKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final userName = _usernameController.text.trim();
      final updates = {
        'username': userName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      ref.watch(authProvider.notifier).updateProfile(updates);

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

  Future<void> _onUpload(String imageUrl, String avatarFileName) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updates = {
        'avatar_url': imageUrl,
        'avatar_filename': avatarFileName,
      };

      ref.watch(authProvider.notifier).updateProfile(updates);

      if (mounted) {
        context.showSnackBar(
            message: '画像をアップロードしました', backgroundColor: Colors.green);
      }
    } catch (e) {
      context.showSnackBarError(
          message: '画像アップロード中にエラーが発生しました:  ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('プロフィール変更'),
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
                  Avatar(
                      imageUrl: auth.profile?.avatarUrl, onUpload: _onUpload),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ユーザー名',
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ユーザー名を入力してください';
                      }
                      final isValid = RegExp(
                              r'^[a-zA-Z0-9_]|[\u3040-\u309F]|\u3000|[\u30A1-\u30FC]|[\u4E00-\u9FFF]{3,24}$')
                          .hasMatch(value);
                      if (!isValid) {
                        return 'ユーザー名はアルファベットか文字で3~24文字以下で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                      onPressed: _isLoading ? null : _updateProfile,
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
