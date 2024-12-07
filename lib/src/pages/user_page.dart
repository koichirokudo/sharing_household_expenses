import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
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
        title: const Text('ユーザー情報'),
      ),
      body: Center(
        child: Container(
          height: 420,
          width: 400,
          decoration: const BoxDecoration(
            color: Color(0x00FFE7D4),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ユーザー名',
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                prefixIcon: Icon(Icons.mail),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: _isObscure,
              decoration: InputDecoration(
                  labelText: 'パスワード',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: _toggleObscure,
                  )),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: _isObscure,
              decoration: InputDecoration(
                  labelText: '再度パスワード',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: _toggleObscure,
                  )),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('保存'),
                  onPressed: () {
                    // TODO: 保存処理
                    Navigator.pop(context, 'テスト');
                  },
                ),
                ElevatedButton(
                  child: const Text('戻る'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
