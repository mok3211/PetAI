import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pet_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  final int petId;
  const PetDetailPage({super.key, required this.petId});

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage> {
  final _name = TextEditingController();
  final _species = TextEditingController();
  bool _saving = false;
  XFile? _picked;
  DateTime? _passed;

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petDetailProvider(widget.petId));
    final update = ref.watch(petUpdaterProvider);
    final Dio dio = ref.watch(dioProvider);
    final remove = ref.watch(petDeleterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('宠物详情')),
      body: pet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
        data: (p) {
          _name.text = p.name;
          _species.text = p.species ?? '';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: '姓名')),
                const SizedBox(height: 12),
                TextField(controller: _species, decoration: const InputDecoration(labelText: '物种')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final x = await picker.pickImage(source: ImageSource.gallery);
                        if (x != null) setState(() { _picked = x; });
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('头像'),
                    ),
                    const SizedBox(width: 12),
                    Text(_picked?.name ?? '未选择'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _passed ?? now,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() { _passed = date; });
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('离世日期'),
                    ),
                    const SizedBox(width: 12),
                    Text(_passed == null ? '未设置' : _passed!.toIso8601String().split('T').first),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                setState(() { _saving = true; });
                                String? portraitUrl;
                                if (_picked != null) {
                                  final form = FormData.fromMap({
                                    'file': await MultipartFile.fromFile(_picked!.path, filename: _picked!.name),
                                  });
                                  final res = await dio.post('/api/v1/uploads', data: form);
                                  portraitUrl = res.data['url'] as String?;
                                }
                                final data = {
                                  'name': _name.text,
                                  'species': _species.text.isEmpty ? null : _species.text,
                                  if (portraitUrl != null) 'portrait_url': portraitUrl,
                                  if (_passed != null) 'passed_date': _passed!.toIso8601String().split('T').first,
                                };
                                await update(widget.petId, data);
                                if (mounted) {
                                  setState(() { _saving = false; });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功')));
                                }
                              },
                        child: _saving ? const CircularProgressIndicator() : const Text('保存'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('确认删除'),
                                content: const Text('删除后不可恢复，确认删除该宠物？'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
                                ],
                              ),
                            ) ??
                            false;
                        if (ok) {
                          await remove(widget.petId);
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
