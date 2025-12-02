import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pet_provider.dart';

class PetMemorialPage extends ConsumerWidget {
  final int petId;
  const PetMemorialPage({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petDetailProvider(petId));
    return Scaffold(
      appBar: AppBar(title: const Text('纪念页')),
      body: pet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
        data: (p) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            if (p.portraitUrl != null && p.portraitUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(p.portraitUrl!, width: 160, height: 160, fit: BoxFit.cover),
              )
            else
              const Icon(Icons.pets, size: 120),
            const SizedBox(height: 16),
            Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(p.species ?? ''),
            const SizedBox(height: 12),
            if (p.notes != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(p.notes!)),
          ],
        ),
      ),
    );
  }
}

