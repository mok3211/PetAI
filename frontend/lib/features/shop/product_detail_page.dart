import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart';
import 'cart_provider.dart';
import '../profile/user_provider.dart';
import 'product_form_page.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _qty = 1;
  bool _adding = false;

  String _formatPrice(int cents) => '¥${(cents / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(productDetailProvider(widget.productId));
    final addToCart = ref.watch(cartAdderProvider);
    final me = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
        actions: [
          me.maybeWhen(
            data: (data) => (data['is_admin'] == true)
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProductFormPage(productId: widget.productId)),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: p.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
        data: (prod) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (prod.imageUrl != null && prod.imageUrl!.isNotEmpty)
                Image.network(prod.imageUrl!, width: double.infinity, height: 240, fit: BoxFit.cover)
              else
                Container(height: 240, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image)) ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prod.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_formatPrice(prod.priceCents), style: const TextStyle(color: Colors.teal, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('库存：${prod.stock}'),
                    const SizedBox(height: 16),
                    Text(prod.description ?? ''),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(onPressed: _qty>1?(){ setState(()=>_qty--); }:null, icon: const Icon(Icons.remove_circle_outline)),
                        Text('$_qty'),
                        IconButton(onPressed: (){ setState(()=>_qty++); }, icon: const Icon(Icons.add_circle_outline)),
                        const Spacer(),
                        FilledButton(
                          onPressed: _adding ? null : () async {
                            setState((){ _adding = true; });
                            await addToCart(prod.id, _qty);
                            if (mounted) {
                              setState((){ _adding = false; });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已加入购物车')));
                            }
                          },
                          child: _adding ? const CircularProgressIndicator() : const Text('加入购物车'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
