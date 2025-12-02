import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class ChatMessageModel {
  final int id;
  final int petId;
  final String role;
  final String content;
  ChatMessageModel({required this.id, required this.petId, required this.role, required this.content});
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as int,
      petId: map['pet_id'] as int,
      role: map['role'] as String,
      content: map['content'] as String,
    );
  }
}

final chatHistoryProvider = FutureProvider.family<List<ChatMessageModel>, int>((ref, petId) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/ai/history/pets/$petId');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map(ChatMessageModel.fromMap).toList();
});

final chatSenderProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int petId, String content) async {
    final res = await dio.post('/api/v1/ai/chat', data: { 'pet_id': petId, 'content': content });
    final list = (res.data as List).cast<Map<String, dynamic>>();
    ref.invalidate(chatHistoryProvider(petId));
    return list.map(ChatMessageModel.fromMap).toList();
  };
});

