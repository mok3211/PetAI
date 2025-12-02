import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pet_provider.dart';

class PetCreatePage extends ConsumerStatefulWidget {
  const PetCreatePage({super.key});

  @override
  ConsumerState<PetCreatePage> createState() => _PetCreatePageState();
}

class _PetCreatePageState extends ConsumerState<PetCreatePage> {
  final _name = TextEditingController();
  final _species = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final create = ref.watch(petCreatorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('创建宠物档案')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: '姓名')),
            const SizedBox(height: 12),
            TextField(controller: _species, decoration: const InputDecoration(labelText: '物种(选填)')),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() { _loading = true; _error = null; });
                        try {
                          await create(_name.text, _species.text.isEmpty ? null : _species.text);
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          setState(() { _error = '创建失败'; });
                        } finally {
                          if (mounted) setState(() { _loading = false; });
                        }
                      },
                child: _loading ? const CircularProgressIndicator() : const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

