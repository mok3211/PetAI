import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_scaffold.dart';
import '../../features/pet/pet_page.dart';
import '../../features/home/share_page.dart';
import '../../features/shop/shop_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/pet/pet_create_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/pets',
    redirect: (context, state) {
      final logging = state.matchedLocation.startsWith('/auth');
      if (!auth.isAuthed && !logging) {
        return '/auth/login';
      }
      if (auth.isAuthed && logging) {
        return '/pets';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/auth/login', name: 'login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/auth/register', name: 'register', builder: (c, s) => const RegisterPage()),
      GoRoute(path: '/pets/new', name: 'pet-create', builder: (c, s) => const PetCreatePage()),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/pets',
            name: 'pets',
            builder: (context, state) => const PetPage(),
          ),
          GoRoute(
            path: '/share',
            name: 'share',
            builder: (context, state) => const SharePage(),
          ),
          GoRoute(
            path: '/shop',
            name: 'shop',
            builder: (context, state) => const ShopPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
});
