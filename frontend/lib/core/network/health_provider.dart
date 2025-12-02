import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dio_client.dart';

final healthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final Dio dio = ref.watch(dioProvider);
  final res = await dio.get('/health');
  return Map<String, dynamic>.from(res.data as Map);
});

