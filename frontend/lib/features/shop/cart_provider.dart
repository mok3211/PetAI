import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class CartItemModel {
  final int id;
  final int productId;
  final int quantity;
  final int unitPriceCents;
  CartItemModel({required this.id, required this.productId, required this.quantity, required this.unitPriceCents});
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      unitPriceCents: map['unit_price_cents'] as int,
    );
  }
}

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final int totalCents;
  CartModel({required this.id, required this.items, required this.totalCents});
  factory CartModel.fromMap(Map<String, dynamic> map) {
    final items = (map['items'] as List).cast<Map<String, dynamic>>().map(CartItemModel.fromMap).toList();
    return CartModel(id: map['id'] as int, items: items, totalCents: map['total_cents'] as int);
  }
}

final cartProvider = FutureProvider<CartModel>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/cart');
  return CartModel.fromMap(Map<String, dynamic>.from(res.data as Map));
});

final cartAdderProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int productId, int quantity) async {
    await dio.post('/api/v1/cart/items', data: { 'product_id': productId, 'quantity': quantity });
    ref.invalidate(cartProvider);
  };
});

final cartUpdaterProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int itemId, int quantity) async {
    await dio.put('/api/v1/cart/items/$itemId', data: { 'product_id': 0, 'quantity': quantity });
    ref.invalidate(cartProvider);
  };
});

final cartDeleterProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int itemId) async {
    await dio.delete('/api/v1/cart/items/$itemId');
    ref.invalidate(cartProvider);
  };
});

final orderCreatorProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return () async {
    final res = await dio.post('/api/v1/orders');
    ref.invalidate(cartProvider);
    return Map<String, dynamic>.from(res.data as Map);
  };
});

