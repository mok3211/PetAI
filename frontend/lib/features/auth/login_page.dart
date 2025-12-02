import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
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
                        final ok = await ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
                        setState(() {
                          _loading = false;
                        });
                        if (ok) {
                          if (!context.canPop()) {
                            context.go('/pets');
                          } else {
                            context.pop();
                          }
                        } else {
                          setState(() {
                            _error = '登录失败';
                          });
                        }
                      },
                child: _loading ? const CircularProgressIndicator() : const Text('登录'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.go('/auth/register'), child: const Text('没有账号？去注册')),
          ],
        ),
      ),
    );
  }
}

