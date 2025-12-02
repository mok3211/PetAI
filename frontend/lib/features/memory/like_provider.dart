import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

final likesCountProvider = FutureProvider.family<int, int>((ref, memoryId) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/likes/memories/$memoryId/count');
  return (res.data['count'] as num).toInt();
});

final likeToggleProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int memoryId) async {
    final res = await dio.post('/api/v1/likes/memories/$memoryId/toggle');
    ref.invalidate(likesCountProvider(memoryId));
    return Map<String, dynamic>.from(res.data as Map);
  };
});

final likesRecentProvider = FutureProvider.family<List<int>, int>((ref, memoryId) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/likes/memories/$memoryId');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map((e) => (e['user_id'] as num).toInt()).toList();
});
