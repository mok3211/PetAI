import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_provider.dart';
import 'product_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  String _formatPrice(int cents) => '¥${(cents / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final update = ref.watch(cartUpdaterProvider);
    final remove = ref.watch(cartDeleterProvider);
    final checkout = ref.watch(orderCreatorProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('购物车')),
      body: cart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
        data: (data) => Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: data.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final it = data.items[i];
                  final prod = ref.watch(productDetailProvider(it.productId));
                  return ListTile(
                    leading: prod.maybeWhen(
                      data: (p) => (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(p.imageUrl!, width: 48, height: 48, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image),
                      orElse: () => const Icon(Icons.image),
                    ),
                    title: prod.maybeWhen(data: (p) => Text(p.name), orElse: () => const Text('加载中...')),
                    subtitle: Text('${_formatPrice(it.unitPriceCents)}  x${it.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: it.quantity>1?() => update(it.id, it.quantity-1):null, icon: const Icon(Icons.remove_circle_outline)),
                        IconButton(onPressed: () => update(it.id, it.quantity+1), icon: const Icon(Icons.add_circle_outline)),
                        IconButton(onPressed: () => remove(it.id), icon: const Icon(Icons.delete, color: Colors.red)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Text('合计：${_formatPrice(data.totalCents)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  FilledButton(
                    onPressed: () async {
                      final res = await checkout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('下单成功：#${res['id']}')));
                      }
                    },
                    child: const Text('下单'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

