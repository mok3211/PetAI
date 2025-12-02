import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

final currentUserProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/users/me');
  return Map<String, dynamic>.from(res.data as Map);
});

final userByIdProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/users/$id');
  if (res.data == null) return null;
  return Map<String, dynamic>.from(res.data as Map);
});
