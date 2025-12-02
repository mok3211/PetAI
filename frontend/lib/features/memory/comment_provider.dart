import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class CommentModel {
  final int id;
  final int memoryId;
  final int userId;
  final String content;
  CommentModel({required this.id, required this.memoryId, required this.userId, required this.content});
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as int,
      memoryId: map['memory_id'] as int,
      userId: map['user_id'] as int,
      content: map['content'] as String,
    );
  }
}

final commentsProvider = FutureProvider.family<List<CommentModel>, int>((ref, memoryId) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/comments/memories/$memoryId');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map(CommentModel.fromMap).toList();
});

final commentCreatorProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int memoryId, String content) async {
    await dio.post('/api/v1/comments', data: { 'memory_id': memoryId, 'content': content });
    ref.invalidate(commentsProvider(memoryId));
  };
});

