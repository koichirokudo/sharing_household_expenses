import 'package:flutter/material.dart';
import 'package:sharing_household_expenses/src/pages/user_register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isObscure = true;

  void _toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ログイン'),
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    prefixIcon: Icon(Icons.mail),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                      labelText: 'パスワード',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: _toggleObscure,
                      )),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                    label: const Text('ログイン'),
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      // TODO: ログイン処理
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(300, double.infinity),
                    )),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  label: const Text('新規登録'),
                  icon: const Icon(Icons.person_add),
                  iconAlignment: IconAlignment.start,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const UserRegisterPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, double.infinity),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
