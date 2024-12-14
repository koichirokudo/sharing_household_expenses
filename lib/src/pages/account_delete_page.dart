import 'package:flutter/material.dart';
import 'package:sharing_household_expenses/services/profile_service.dart';
import 'package:sharing_household_expenses/services/transaction_service.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';

class AccountDeletePage extends StatefulWidget {
  const AccountDeletePage({super.key});

  @override
  AccountDeletePageState createState() => AccountDeletePageState();
}

class AccountDeletePageState extends State<AccountDeletePage> {
  bool _isLoading = false;
  late Map<String, dynamic> profile;
  late final ProfileService profileService;
  late final TransactionService transactionService;

  Future<void> _getProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      profile = await profileService.fetchProfile();
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

  Future<void> _accountDelete() async {
    try {
      transactionService.clearAllCache();
      final response = await supabase.functions.invoke("delete-user");
      if (response.data['success'] == true) {
        await supabase.auth.signOut();
      }

      if (mounted) {
        context.showSnackBar(
            message: 'アカウントを削除しました', backgroundColor: Colors.green);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false);
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        context.showSnackBar(message: '$error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    profileService = ProfileService(supabase);
    transactionService = TransactionService(supabase);
    _getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('アカウント削除'),
      ),
      body: Center(
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
                        content: Text('本アプリ上にあるすべてのデータが削除されます。本当によろしいですか？'),
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
