import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'memory_provider.dart';

class MemoryCreatePage extends ConsumerStatefulWidget {
  final int petId;
  const MemoryCreatePage({super.key, required this.petId});

  @override
  ConsumerState<MemoryCreatePage> createState() => _MemoryCreatePageState();
}

class _MemoryCreatePageState extends ConsumerState<MemoryCreatePage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _loading = false;
  String? _error;
  XFile? _picked;
  bool _public = false;

  @override
  Widget build(BuildContext context) {
    final create = ref.watch(memoryCreatorProvider);
    final Dio dio = ref.watch(dioProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('新增笔记')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: '标题')),
            const SizedBox(height: 12),
            TextField(controller: _content, maxLines: 5, decoration: const InputDecoration(labelText: '内容')),
            const SizedBox(height: 20),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final x = await picker.pickImage(source: ImageSource.gallery);
                    if (x != null) {
                      setState(() { _picked = x; });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('选择图片'),
                ),
                const SizedBox(width: 12),
                if (_picked != null)
                  Text(_picked!.name, overflow: TextOverflow.ellipsis),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('公开分享'),
                const SizedBox(width: 12),
                Switch(value: _public, onChanged: (v) => setState(() => _public = v)),
              ],
            ),
            const SizedBox(height: 12),
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
                          String? mediaUrl;
                          if (_picked != null) {
                            final form = FormData.fromMap({
                              'file': await MultipartFile.fromFile(_picked!.path, filename: _picked!.name),
                            });
                            final res = await dio.post('/api/v1/uploads', data: form);
                            mediaUrl = res.data['url'] as String?;
                          }
                          await create(
                            widget.petId,
                            _title.text,
                            _content.text.isEmpty ? null : _content.text,
                            mediaUrl: mediaUrl,
                            isPublic: _public,
                          );
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
