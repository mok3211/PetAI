import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class AuthState {
  final String? token;
  const AuthState({this.token});
  bool get isAuthed => token != null && token!.isNotEmpty;
  AuthState copyWith({String? token}) => AuthState(token: token ?? this.token);
}

class AuthController extends StateNotifier<AuthState> {
  final Dio dio;
  AuthController(this.dio) : super(const AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('access_token');
    if (t != null && t.isNotEmpty) {
      state = state.copyWith(token: t);
    }
  }

  Future<bool> login(String email, String password) async {
    final res = await dio.post('/api/v1/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['access_token'] as String?;
    if (token != null && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      state = state.copyWith(token: token);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    state = const AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthController(dio);
});

