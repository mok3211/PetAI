import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_provider.dart';
import 'product_model.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import '../profile/user_provider.dart';
import 'product_form_page.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final me = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('商城'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartPage()),
            ),
          ),
          me.maybeWhen(
            data: (data) => (data['is_admin'] == true)
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductFormPage()),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('暂无商品'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              return _ProductCard(p: p, onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProductDetailPage(productId: p.id)),
                );
              });
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel p;
  final VoidCallback onTap;
  const _ProductCard({required this.p, required this.onTap});

  String _formatPrice(int cents) {
    return '¥${(cents / 100).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                  ? Image.network(p.imageUrl!, width: double.infinity, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image))),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_formatPrice(p.priceCents), style: const TextStyle(color: Colors.teal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
