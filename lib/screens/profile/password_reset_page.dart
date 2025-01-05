import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  PasswordResetPageState createState() => PasswordResetPageState();
}

class PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  bool _isObscure = true;
  bool _isLoading = false;
  bool _isAuthEmail = false;
  final _fromKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState;
    _handleIncomingLinks();
  }

  Future<void> _resetPassword() async {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final email = user?.email;

    if (user == null || email == null) {
      context.showSnackBarError(message: 'ログインが必要です');
      return;
    }

    try {
      await ref
          .watch(authProvider.notifier)
          .sendResetPasswordEmail(email: email);
      if (mounted) {
        context.showSnackBar(
            message: 'リセットメールを送信しました', backgroundColor: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(message: '$e');
      }
    }
  }

  Future<void> _updatePassword() async {
    final isValid = _fromKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .watch(authProvider.notifier)
          .updateUser(password: _passwordController.text);
      _passwordController.clear();
      if (mounted) {
        context.showSnackBar(
            message: 'パスワードを変更しました', backgroundColor: Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarError(
            message: 'パスワード変更中にエラーが発生しました: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  // deep link を開いたときの動作
  void _handleIncomingLinks() {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == 'reset-password') {
        setState(() {
          _isAuthEmail = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('パスワードリセット'),
      ),
      body: _isAuthEmail == false
          ? Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.mail),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(400, double.infinity),
                        minimumSize: Size(400, 50),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('パスワードをリセットする'),
                                content: Text(
                                    'パスワードリセットメールを登録済みのメールアドレスへ送信します。よろしいですか？'),
                                actions: [
                                  TextButton(
                                    child: Text('はい'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _resetPassword();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('いいえ'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      label: Text('パスワードリセットメールを送信する'),
                    ),
                  ],
                ),
              ),
            )
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
                        const SizedBox(height: 32),
                        TextFormField(
                          obscureText: _isObscure,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'パスワード',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: _toggleObscure,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを入力してください';
                            }
                            if (!RegExp(r'^.{8,24}$').hasMatch(value)) {
                              return 'パスワードは8~24文字で入力してください';
                            }
                            if (!RegExp(
                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,24}$')
                                .hasMatch(value)) {
                              return 'パスワードには大文字、小文字、数字、記号を含めてください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                            onPressed: _isLoading ? null : _updatePassword,
                            label: Text(_isLoading ? '' : 'パスワードを設定する'),
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
