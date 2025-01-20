import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/user_group_provider.dart';
import '../screens/report/report_page.dart';

class TitleRow extends ConsumerWidget {
  final bool shared;

  const TitleRow({
    super.key,
    required this.shared,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).profile;
    final profiles = ref.watch(authProvider).profiles;
    final groupName = ref.watch(userGroupProvider).group?.groupName;
    final avatarUrl = profile?.avatarUrl;
    final username = profile?.username;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (shared) ...[
            ...?profiles?.map((item) {
              return Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: item.avatarUrl != null
                        ? NetworkImage(item.avatarUrl.toString())
                        : AssetImage('assets/icons/user_icon.png'),
                  ),
                ),
              );
            }),
          ] else ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: avatarUrl != null
                      ? NetworkImage(avatarUrl.toString())
                      : AssetImage('assets/icons/user_icon.png'),
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Text(
            shared ? (groupName ?? 'グループ') : (username ?? '個人'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportPage(shared: shared),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
