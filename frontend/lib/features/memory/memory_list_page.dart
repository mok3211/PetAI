import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'memory_provider.dart';
import 'memory_edit_page.dart';
import 'memory_create_page.dart';
import 'like_provider.dart';
import 'comment_list_page.dart';
import '../profile/user_provider.dart';

class MemoryListPage extends ConsumerWidget {
  final int petId;
  const MemoryListPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider(petId));
    return Scaffold(
      appBar: AppBar(title: const Text('时光轴')),
      body: memories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('加载失败')),
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final m = list[i];
            final likes = ref.watch(likesCountProvider(m.id));
            return ListTile(
              leading: m.mediaUrl != null && m.mediaUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(m.mediaUrl!, width: 48, height: 48, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.note),
              title: Text(m.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.content ?? ''),
                  const SizedBox(height: 4),
                  Consumer(builder: (context, ref, _) {
                    final recent = ref.watch(likesRecentProvider(m.id));
                    return recent.when(
                      loading: () => const SizedBox.shrink(),
                      error: (e, st) => const SizedBox.shrink(),
                      data: (userIds) {
                        if (userIds.isEmpty) return const SizedBox.shrink();
                        return SizedBox(
                          height: 28,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: userIds.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 6),
                            itemBuilder: (context, i) {
                              return Consumer(builder: (context, ref, _) {
                                final u = ref.watch(userByIdProvider(userIds[i]));
                                return u.maybeWhen(
                                  data: (data) {
                                    final url = data?['avatar_url'] as String?;
                                    return CircleAvatar(
                                      radius: 12,
                                      backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
                                      child: (url == null || url.isEmpty) ? const Icon(Icons.person, size: 16) : null,
                                    );
                                  },
                                  orElse: () => const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 16)),
                                );
                              });
                            },
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  likes.when(
                    data: (c) => Text('$c'),
                    loading: () => const Text('...'),
                    error: (e, st) => const Text('!'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () async { await ref.read(likeToggleProvider)(m.id); },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MemoryEditPage(
                          petId: petId,
                          memoryId: m.id,
                          initTitle: m.title,
                          initContent: m.content,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('确认删除'),
                              content: const Text('删除后不可恢复，确认删除该笔记？'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
                              ],
                            ),
                          ) ??
                          false;
                      if (ok) {
                        await ref.read(memoryDeleterProvider)(petId, m.id);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CommentListPage(memoryId: m.id)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MemoryCreatePage(petId: petId)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
