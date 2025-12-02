import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'product_model.dart';

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/products');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map(ProductModel.fromMap).toList();
});

final productDetailProvider = FutureProvider.family<ProductModel, int>((ref, id) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/products/$id');
  return ProductModel.fromMap(Map<String, dynamic>.from(res.data as Map));
});

final productCreatorProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (Map<String, dynamic> data) async {
    final res = await dio.post('/api/v1/products', data: data);
    ref.invalidate(productsProvider);
    return Map<String, dynamic>.from(res.data as Map);
  };
});

final productUpdaterProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int id, Map<String, dynamic> data) async {
    final res = await dio.put('/api/v1/products/$id', data: data);
    ref.invalidate(productsProvider);
    ref.invalidate(productDetailProvider(id));
    return Map<String, dynamic>.from(res.data as Map);
  };
});
