import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_provider.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final setAdmin = ref.watch(setAdminProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('管理用户')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final u = list[i];
            final url = u['avatar_url'] as String?;
            final isAdmin = u['is_admin'] == true;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
                child: (url == null || url.isEmpty) ? const Icon(Icons.person) : null,
              ),
              title: Text(u['email'] as String),
              subtitle: Text((u['nickname'] as String?) ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('管理员'),
                  Switch(
                    value: isAdmin,
                    onChanged: (v) async { await setAdmin((u['id'] as num).toInt(), v); },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

