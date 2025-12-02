import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'memory_provider.dart';

class MemoryEditPage extends ConsumerStatefulWidget {
  final int petId;
  final int memoryId;
  final String initTitle;
  final String? initContent;
  const MemoryEditPage({super.key, required this.petId, required this.memoryId, required this.initTitle, this.initContent});

  @override
  ConsumerState<MemoryEditPage> createState() => _MemoryEditPageState();
}

class _MemoryEditPageState extends ConsumerState<MemoryEditPage> {
  late TextEditingController _title;
  late TextEditingController _content;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initTitle);
    _content = TextEditingController(text: widget.initContent ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(memoryUpdaterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('编辑笔记')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: '标题')),
            const SizedBox(height: 12),
            TextField(controller: _content, maxLines: 5, decoration: const InputDecoration(labelText: '内容')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() { _saving = true; });
                        await update(widget.memoryId, _title.text, _content.text.isEmpty ? null : _content.text);
                        if (mounted) Navigator.pop(context);
                      },
                child: _saving ? const CircularProgressIndicator() : const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

