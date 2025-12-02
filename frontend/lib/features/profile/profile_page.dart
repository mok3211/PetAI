import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import 'user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../admin/admin_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  XFile? _picked;
  final _nickname = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);
    final Dio dio = ref.watch(dioProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: Center(
        child: user.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => Text(auth.isAuthed ? '获取用户失败' : '未登录'),
          data: (data) {
            final url = data['avatar_url'] as String?;
            _nickname.text = (data['nickname'] as String?) ?? '';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
                  child: (url == null || url.isEmpty) ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 12),
                Text('邮箱: ${data['email']}'),
                const SizedBox(height: 12),
                SizedBox(
                  width: 240,
                  child: TextField(controller: _nickname, decoration: const InputDecoration(labelText: '昵称')),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final x = await picker.pickImage(source: ImageSource.gallery);
                        if (x != null) setState(() { _picked = x; });
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('选择头像'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _saving ? null : () async {
                        setState(() { _saving = true; });
                        String? avatarUrl = url;
                        if (_picked != null) {
                          final form = FormData.fromMap({ 'file': await MultipartFile.fromFile(_picked!.path, filename: _picked!.name) });
                          final res = await dio.post('/api/v1/uploads', data: form);
                          avatarUrl = res.data['url'] as String?;
                        }
                        await dio.put('/api/v1/users/me', data: {
                          'nickname': _nickname.text.isEmpty ? null : _nickname.text,
                          'avatar_url': avatarUrl,
                        });
                        ref.invalidate(currentUserProvider);
                        if (mounted) setState(() { _saving = false; });
                      },
                      child: _saving ? const CircularProgressIndicator() : const Text('保存资料'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer(builder: (context, ref, _) {
                  final me = ref.watch(currentUserProvider);
                  return me.maybeWhen(
                    data: (data) => (data['is_admin'] == true)
                        ? FilledButton.tonal(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AdminPage()),
                            ),
                            child: const Text('管理用户'),
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  );
                }),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  child: const Text('退出登录'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
