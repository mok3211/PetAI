import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(label: '宠物中心', icon: Icons.pets, location: '/pets'),
      _NavItem(label: '分享', icon: Icons.public, location: '/share'),
      _NavItem(label: '商城', icon: Icons.store, location: '/shop'),
      _NavItem(label: '我的', icon: Icons.person, location: '/profile'),
    ];
    final router = GoRouter.of(context);
    final loc = router.routeInformationProvider.value.uri.toString();
    var index = items.indexWhere((e) => loc.startsWith(e.location));
    index = index < 0 ? 0 : index;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: items
            .map((e) => NavigationDestination(icon: Icon(e.icon), label: e.label))
            .toList(),
        onDestinationSelected: (i) {
          final target = items[i];
          if (!loc.startsWith(target.location)) {
            context.go(target.location);
          }
        },
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String location;
  const _NavItem({required this.label, required this.icon, required this.location});
}
