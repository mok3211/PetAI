import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/health_provider.dart';
import 'pet_provider.dart';
import 'pet_detail_page.dart';
import 'pet_memorial_page.dart';
import '../memory/memory_list_page.dart';
import 'pet_create_page.dart';
import '../ai/chat_page.dart';

class PetPage extends ConsumerWidget {
  const PetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthProvider);
    final pets = ref.watch(petsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('宠物中心')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: health.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('服务不可用: $e'),
              data: (data) => Text('服务状态: ${data['status']}'),
            ),
          ),
          Expanded(
            child: pets.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('获取宠物失败')), 
              data: (list) => ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = list[i];
                  return ListTile(
                    leading: const Icon(Icons.pets),
                    title: Text(p.name),
                    subtitle: Text(p.species ?? '未填写物种'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MemoryListPage(petId: p.id)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ChatPage(petId: p.id)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => PetDetailPage(petId: p.id)),
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PetMemorialPage(petId: p.id)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PetCreatePage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
