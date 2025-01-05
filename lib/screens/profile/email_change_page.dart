import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

import '../../providers/auth_provider.dart';

class EmailChangePage extends ConsumerStatefulWidget {
  const EmailChangePage({super.key});

  @override
  EmailChangePageState createState() => EmailChangePageState();
}

class EmailChangePageState extends ConsumerState<EmailChangePage> {
  bool _isLoading = false;
  bool _isAuthEmail = false;
  final _fromKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  Future<void> _updateEmail() async {
    final isValid = _fromKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null || user.email == null) {
      context.showSnackBarError(message: 'ログインが必要です');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .watch(authProvider.notifier)
          .updateUser(email: _emailController.text.trim());

      if (mounted) {
        context.showSnackBar(
            message: '指定したメールアドレスにメールを送信しました', backgroundColor: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(
            message: 'メールアドレス変更中にエラーが発生しました: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleIncomingLinks() {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == 'change-email') {
        _isAuthEmail = true;
        if (mounted) {
          context.showSnackBar(
              message: 'メールアドレスを変更しました', backgroundColor: Colors.green);
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('メールアドレス変更'),
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
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'メールアドレス',
                      prefixIcon: const Icon(Icons.mail),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メールアドレスを入力してください';
                      }
                      final isValid = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value);
                      if (!isValid) {
                        return '正しいメールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _confirmEmailController,
                    decoration: InputDecoration(
                      labelText: 'メールアドレス（再入力）',
                      prefixIcon: const Icon(Icons.mail),
                    ),
                    validator: (value) {
                      if (value != _emailController.text.trim()) {
                        return '1回目と同じメールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                      onPressed: _isLoading ? null : _updateEmail,
                      label: Text(_isLoading ? '' : '認証メールを送信する'),
                      icon: _isLoading
                          ? CircularProgressIndicator()
                          : Icon(Icons.mail),
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
