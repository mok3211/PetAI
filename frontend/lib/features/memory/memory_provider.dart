import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'memory_model.dart';

final memoriesProvider = FutureProvider.family<List<MemoryModel>, int>((ref, petId) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/memories/pets/$petId');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map(MemoryModel.fromMap).toList();
});

final memoryCreatorProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int petId, String title, String? content, {String? mediaUrl, bool isPublic = false}) async {
    await dio.post('/api/v1/memories/', data: {
      'pet_id': petId,
      'title': title,
      'content': content,
      'media_url': mediaUrl,
      'is_public': isPublic,
    });
    ref.invalidate(memoriesProvider(petId));
  };
});

final memoryUpdaterProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int id, String title, String? content) async {
    await dio.put('/api/v1/memories/$id', data: {
      'title': title,
      'content': content,
    });
  };
});

final memoryDeleterProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int petId, int id) async {
    await dio.delete('/api/v1/memories/$id');
    ref.invalidate(memoriesProvider(petId));
  };
});
