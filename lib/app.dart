import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharing_household_expenses/providers/auth_provider.dart';
import 'package:sharing_household_expenses/providers/category_provider.dart';
import 'package:sharing_household_expenses/providers/user_group_provider.dart';
import 'package:sharing_household_expenses/screens/home/home_page.dart';
import 'package:sharing_household_expenses/screens/settlement/settlement_list_page.dart';
import 'package:sharing_household_expenses/screens/sign_in/sign_in.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_list_page.dart';
import 'package:sharing_household_expenses/screens/transaction/transaction_register_page.dart';
import 'package:sharing_household_expenses/utils/constants.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Future(
        () async {
          // 初回データ取得
          await ref.read(authProvider.notifier).fetchProfile();
          await ref.read(authProvider.notifier).fetchProfiles();
          await ref.read(categoryProvider.notifier).fetchCategories();
          final groupId = ref.read(authProvider).profile?.groupId;
          if (groupId != null) {
            // ユーザーグループ取得
            await ref.read(userGroupProvider.notifier).fetchGroup(groupId);
          }
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0x00ff5500),
            ),
          );
        }
        return MaterialApp(
          title: 'シェア家計簿',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0x00ff5500),
            ),
            useMaterial3: true,
            fontFamily: 'MPLUS1p',
          ),
          home: supabase.auth.currentUser == null
              ? const SignInPage()
              : const App(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ja', 'JP'),
          ],
          locale: const Locale('ja', 'JP'),
        );
      },
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  static const _screens = [
    HomePage(),
    TransactionRegisterPage(),
    TransactionListPage(),
    SettlementListPage(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '登録'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '明細一覧'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check), label: '清算一覧'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
