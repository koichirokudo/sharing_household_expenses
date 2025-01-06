import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/screens/sign_in/sign_in.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class AccountDeletePage extends ConsumerStatefulWidget {
  const AccountDeletePage({super.key});

  @override
  AccountDeletePageState createState() => AccountDeletePageState();
}

class AccountDeletePageState extends ConsumerState<AccountDeletePage> {
  bool _isLoading = false;
  late Map<String, dynamic> profile;

  Future<void> _accountDelete() async {
    final authNotifier = ref.watch(authProvider.notifier);
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await authNotifier.deleteUser();
      if (response == true) {
        await authNotifier.signOut();
      } else {
        throw Exception('アカウントの削除に失敗しました');
      }

      if (mounted) {
        context.showSnackBar(
          message: 'アカウントを削除しました。ご利用ありがとうございました',
          backgroundColor: Colors.green,
        );
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignInPage()),
            (route) => false);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(message: 'アカウント削除中にエラーが発生しました: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('アカウント削除'),
      ),
      body: _isLoading
          ? circularIndicator
          : Center(
              child: Column(
                children: [
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
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('アカウントを削除します'),
                              content:
                                  Text('本アプリ上にあるすべてのデータが削除されます。本当によろしいですか？'),
                              actions: [
                                TextButton(
                                  child: Text('はい'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _accountDelete();
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
                    child: const Text('アカウントを削除する'),
                  ),
                ],
              ),
            ),
    );
  }
}
