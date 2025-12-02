import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'product_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final int? productId;
  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '0');
  bool _saving = false;
  XFile? _picked;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final Dio dio = ref.watch(dioProvider);
    final create = ref.watch(productCreatorProvider);
    final update = ref.watch(productUpdaterProvider);
    final detail = widget.productId != null ? ref.watch(productDetailProvider(widget.productId!)) : null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.productId == null ? '创建商品' : '编辑商品')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (detail != null)
              detail.maybeWhen(
                data: (p) {
                  _name.text = p.name;
                  _desc.text = p.description ?? '';
                  _price.text = p.priceCents.toString();
                  _stock.text = p.stock.toString();
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              ),
            TextField(controller: _name, decoration: const InputDecoration(labelText: '名称')),
            if ((_error ?? '').contains('name')) Align(alignment: Alignment.centerLeft, child: Text('名称不能为空', style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 12),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: '描述')),
            const SizedBox(height: 12),
            TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '价格(分)')),
            if ((_error ?? '').contains('price')) Align(alignment: Alignment.centerLeft, child: Text('价格需为正整数', style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 12),
            TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '库存')),
            if ((_error ?? '').contains('stock')) Align(alignment: Alignment.centerLeft, child: Text('库存不可为负', style: const TextStyle(color: Colors.red))),
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
                  label: const Text('商品图片'),
                ),
                const SizedBox(width: 12),
                Text(_picked?.name ?? '未选择'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : () async {
                  setState(() { _saving = true; });
                  String? imageUrl;
                  if (_picked != null) {
                    final form = FormData.fromMap({ 'file': await MultipartFile.fromFile(_picked!.path, filename: _picked!.name) });
                    final res = await dio.post('/api/v1/uploads', data: form);
                    imageUrl = res.data['url'] as String?;
                  }
                  final price = int.tryParse(_price.text) ?? -1;
                  final stock = int.tryParse(_stock.text) ?? -1;
                  _error = null;
                  if (_name.text.trim().isEmpty) _error = 'name';
                  else if (price <= 0) _error = 'price';
                  else if (stock < 0) _error = 'stock';
                  if (_error != null) {
                    setState(() { _saving = false; });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请修正表单错误')));
                    return;
                  }
                  final data = {
                    'name': _name.text,
                    'description': _desc.text.isEmpty ? null : _desc.text,
                    'price_cents': price,
                    'stock': stock,
                    if (imageUrl != null) 'image_url': imageUrl,
                  };
                  try {
                    if (widget.productId == null) {
                      await create(data);
                    } else {
                      await update(widget.productId!, data);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
                  }
                  if (mounted) {
                    setState(() { _saving = false; });
                    Navigator.pop(context);
                  }
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
