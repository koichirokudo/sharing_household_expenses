import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/screens/group/first_group_invite_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';

class UserRegisterPage extends ConsumerStatefulWidget {
  const UserRegisterPage({super.key});

  @override
  UserRegisterPageState createState() => UserRegisterPageState();
}

class UserRegisterPageState extends ConsumerState<UserRegisterPage> {
  bool _isObscure = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    try {
      final authNotifier = ref.watch(authProvider.notifier);
      final username = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await Future.delayed(Duration(milliseconds: 350));
      await authNotifier.signUpUser(
        email: email,
        password: password,
        username: username,
      );

      if (mounted) {
        context.showSnackBar(
            message: '登録が完了しました', backgroundColor: Colors.green);
        // グループ招待ページ
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const FirstGroupInvitePage(),
            ),
            (route) => false);
      }
    } on AuthException catch (error) {
      if (mounted) {
        context.showSnackBarError(message: error.message);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBarError(message: unexpectedErrorMessage);
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

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ユーザー登録'),
      ),
      body: auth.isLoading == true
          ? circularIndicator
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
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
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'メールアドレス',
                            prefixIcon: Icon(Icons.mail),
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
                        const SizedBox(height: 16.0),
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
                        const SizedBox(height: 32.0),
                        ElevatedButton.icon(
                          label: const Text('登録'),
                          icon: const Icon(Icons.person_add),
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(400, double.infinity),
                          ),
                        ),
                        ElevatedButton.icon(
                          label: const Text('戻る'),
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(400, double.infinity),
                          ),
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
