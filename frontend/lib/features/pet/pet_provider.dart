import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'pet_model.dart';

final petsListProvider = FutureProvider<List<PetModel>>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/pets/');
  final list = (res.data as List).cast<Map<String, dynamic>>();
  return list.map(PetModel.fromMap).toList();
});

final petDetailProvider = FutureProvider.family<PetModel, int>((ref, id) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/api/v1/pets/$id');
  return PetModel.fromMap(Map<String, dynamic>.from(res.data as Map));
});

final petUpdaterProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int id, Map<String, dynamic> data) async {
    await dio.put('/api/v1/pets/$id', data: data);
    ref.invalidate(petsListProvider);
    ref.invalidate(petDetailProvider(id));
  };
});

final petDeleterProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (int id) async {
    await dio.delete('/api/v1/pets/$id');
    ref.invalidate(petsListProvider);
  };
});

final petCreatorProvider = Provider((ref) {
  final Dio dio = ref.watch(dioProvider);
  return (String name, String? species) async {
    await dio.post('/api/v1/pets/', data: {
      'name': name,
      'species': species,
    });
    ref.invalidate(petsListProvider);
  };
});
