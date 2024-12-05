import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sharing_household_expenses/src/pages/user_page.dart';
import 'package:sharing_household_expenses/utils/cache.dart';
import 'package:sharing_household_expenses/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Session? session = supabase.auth.currentSession;
  // TODO: バックエンドで招待コードの生成
  final String inviteCode = 'ABCDEFG';
  final String inviteLink =
      'https://yrlckprhukvnyirjifaa.supabase.co/invite?code=ABCDEFG';

  // LINE用のDeep Link生成
  String generateLineShareUrl(String code, String link) {
    final message =
        'シェア家計簿のグループ招待です。グループに参加してね！\n招待コード: $code\nこちらのリンクから参加: $link';
    return 'https://line.me/R/share?text=${Uri.encodeComponent(message)}';
  }

  // Deep Linkを開く
  Future<void> openLink(String url) async {
    // URLをUri型に変換
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // 外部アプリでURLを開く
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // TODO: サーバーからデータを取得する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('シェア家計簿'),
        actions: [
          // 招待ボタン（ログイン状態によって表示）
          if (session != null)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 16),
                          const Text(
                            'グループに招待する',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final lineShareUrl =
                                  generateLineShareUrl(inviteCode, inviteLink);
                              openLink(lineShareUrl);
                            },
                            child: const Text('招待コードを送る'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

          // ログイン状態によって表示を変えるアカウントボタンまたはログインボタン
          IconButton(
            icon: session != null
                ? const Icon(Icons.account_circle)
                : const Icon(Icons.login),
            onPressed: () {
              if (session != null) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UserPage()));
              } else {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
          ),
          if (session != null)
            IconButton(
                onPressed: () {
                  clearAllCache();
                  supabase.auth.signOut();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginPage()));
                },
                icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          '今月の収支',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: 0.3,
                        title: '収入',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: 0.7,
                        title: '支出',
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: 0.3,
                        title: 'グループの収入',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: 0.7,
                        title: 'グループの支出',
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 個人の収支
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Icon(
                    Icons.account_circle,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '個人',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ]),
              ),
              const Divider(height: 1, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '収入',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '¥100,000',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_down,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '支出',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '¥100,000',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // グループの収支
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Icon(
                    Icons.group,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'グループ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ]),
              ),
              const Divider(height: 1, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '収入',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '¥100,000',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_down,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '支出',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '¥100,000',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
