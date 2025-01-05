import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/screens/group/group_invite_page.dart';
import 'package:sharing_household_expenses/screens/policy/privacy_policy_page.dart';
import 'package:sharing_household_expenses/screens/policy/terms_of_service_page.dart';
import 'package:sharing_household_expenses/screens/profile/account_delete_page.dart';
import 'package:sharing_household_expenses/screens/profile/email_change_page.dart';
import 'package:sharing_household_expenses/screens/profile/password_reset_page.dart';
import 'package:sharing_household_expenses/screens/profile/profile_edit_page.dart';
import 'package:sharing_household_expenses/screens/sign_in/sign_in.dart';
import 'package:sharing_household_expenses/services/transaction_service.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends ConsumerState {
  late TransactionService transactionService;

  @override
  void initState() {
    super.initState;
    transactionService = TransactionService(supabase);
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
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
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
                      builder: (context) => const EmailChangePage()));
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
                      builder: (context) => const PasswordResetPage()));
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
                      builder: (context) => const GroupInvitePage()));
                },
                child: const Text('グループ招待'),
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
                      builder: (context) => const TermsOfServicePage()));
                },
                child: const Text('利用規約'),
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
                      builder: (context) => const PrivacyPolicyPage()));
                },
                child: const Text('プライバシーポリシー'),
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
                  transactionService.clearAllCache();
                  ref.watch(authProvider.notifier).signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const SignInPage()),
                      (route) => false);
                },
                child: const Text('ログアウト'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
