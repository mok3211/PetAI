import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../memory/memory_model.dart';

final publicMemoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/memories/public');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map(MemoryModel.fromMap).toList();
});

