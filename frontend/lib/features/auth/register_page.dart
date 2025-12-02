import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import 'auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final Dio dio = ref.watch(dioProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: '邮箱')),
            const SizedBox(height: 12),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        try {
                          await dio.post('/api/v1/auth/register', data: {
                            'email': _email.text,
                            'password': _password.text,
                          });
                          final ok = await ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
                          if (ok) {
                            context.go('/pets');
                          } else {
                            setState(() {
                              _error = '自动登录失败';
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _error = '注册失败';
                          });
                        } finally {
                          setState(() {
                            _loading = false;
                          });
                        }
                      },
                child: _loading ? const CircularProgressIndicator() : const Text('注册并登录'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.go('/auth/login'), child: const Text('已有账号？去登录')),
          ],
        ),
      ),
    );
  }
}
