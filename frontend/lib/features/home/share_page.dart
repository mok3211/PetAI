import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'share_provider.dart';
import '../memory/memory_model.dart';

class SharePage extends ConsumerWidget {
  const SharePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(publicMemoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('分享')),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('加载失败')),
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) => _MemoryCard(m: items[i]),
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryModel m;
  const _MemoryCard({required this.m});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: m.mediaUrl != null && m.mediaUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(m.mediaUrl!, width: 48, height: 48, fit: BoxFit.cover),
            )
          : const Icon(Icons.public),
      title: Text(m.title),
      subtitle: Text(m.content ?? ''),
    );
  }
}
