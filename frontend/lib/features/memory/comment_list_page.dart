import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment_provider.dart';
import '../profile/user_provider.dart';

class CommentListPage extends ConsumerStatefulWidget {
  final int memoryId;
  const CommentListPage({super.key, required this.memoryId});

  @override
  ConsumerState<CommentListPage> createState() => _CommentListPageState();
}

class _CommentListPageState extends ConsumerState<CommentListPage> {
  final _content = TextEditingController();
  bool _posting = false;

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.memoryId));
    final create = ref.watch(commentCreatorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('评论')),
      body: Column(
        children: [
          Expanded(
            child: comments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Center(child: Text('加载失败')),
              data: (list) => ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = list[i];
                  return ListTile(
                    leading: Consumer(builder: (context, ref, _) {
                      final u = ref.watch(userByIdProvider(c.userId));
                      return u.maybeWhen(
                        data: (data) {
                          final url = data?['avatar_url'] as String?;
                          return CircleAvatar(
                            backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
                            child: (url == null || url.isEmpty) ? const Icon(Icons.person) : null,
                          );
                        },
                        orElse: () => const CircleAvatar(child: Icon(Icons.person)),
                      );
                    }),
                    title: Text(c.content),
                    subtitle: Consumer(builder: (context, ref, _) {
                      final u = ref.watch(userByIdProvider(c.userId));
                      return u.maybeWhen(
                        data: (data) => Text((data?['nickname'] as String?) ?? '用户#${c.userId}'),
                        orElse: () => Text('用户#${c.userId}'),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _content, decoration: const InputDecoration(hintText: '写下你的评论'))),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _posting ? null : () async {
                    setState((){ _posting = true; });
                    await create(widget.memoryId, _content.text);
                    _content.clear();
                    if (mounted) setState((){ _posting = false; });
                  },
                  child: _posting ? const CircularProgressIndicator() : const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
