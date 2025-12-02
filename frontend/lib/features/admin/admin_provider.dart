import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

final usersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/users');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list;
});

final setAdminProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int userId, bool isAdmin) async {
    await dio.put('/api/v1/users/$userId/admin', data: { 'is_admin': isAdmin });
    ref.invalidate(usersProvider);
  };
});

