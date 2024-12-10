import 'package:flutter/material.dart';
import 'package:sharing_household_expenses/src/pages/account_delete_page.dart';
import 'package:sharing_household_expenses/src/pages/email_edit_page.dart';
import 'package:sharing_household_expenses/src/pages/password_change_page.dart';
import 'package:sharing_household_expenses/src/pages/profile_edit_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ユーザー情報'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(400, double.infinity),
                  minimumSize: Size(400, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProfileEditPage()));
                },
                child: const Text('プロフィール変更'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(400, double.infinity),
                  minimumSize: Size(400, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EmailEditPage()));
                },
                child: const Text('メールアドレス変更'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(400, double.infinity),
                  minimumSize: Size(400, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PasswordChangePage()));
                },
                child: const Text('パスワード変更'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(400, double.infinity),
                  minimumSize: Size(400, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AccountDeletePage()));
                },
                child: const Text('アカウント削除'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
