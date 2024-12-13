import 'package:flutter/material.dart';
import 'package:sharing_household_expenses/services/profile_service.dart';
import 'package:sharing_household_expenses/src/components/avatar.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ProfileEditPageState createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfileEditPage> {
  bool _isLoading = true;
  String? _avatarUrl;
  late final ProfileService profileService;
  final _fromKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  Future<void> _getProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await profileService.fetchProfile();
      _usernameController.text = (data['username'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: '$error');
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

  Future<void> _updateProfile() async {
    final isValid = _fromKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userName = _usernameController.text.trim();
    final userId = supabase.auth.currentUser!.id;
    final updates = {
      'username': userName,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await profileService.updateProfile(userId, updates);
      if (mounted) {
        context.showSnackBar(message: '更新しました', backgroundColor: Colors.green);
      }
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBarError(message: '$error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onUpload(String imageUrl, String avatarFileName) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final updates = {
        'avatar_url': imageUrl,
        'avatar_filename': avatarFileName,
      };

      await profileService.updateProfile(userId, updates);

      if (mounted) {
        context.showSnackBar(
            message: '画像をアップロードしました', backgroundColor: Colors.green);
      }
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBarError(message: '$error');
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: 'Unexpected error occurred');
      }
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    profileService = ProfileService(supabase);
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Avatar(imageUrl: _avatarUrl, onUpload: _onUpload),
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
