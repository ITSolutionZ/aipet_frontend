import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'custom_bottom_navigation.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith('/home')) {
      return 0;
    } else if (location.startsWith('/ai')) {
      return 1;
    } else if (location.startsWith('/scheduling')) {
      return 2;
    } else if (location.startsWith('/settings/push-notification')) {
      return 3;
    } else if (location.startsWith('/settings')) {
      return 4;
    }

    return 0; // 기본값
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/ai');
        break;
      case 2:
        context.go('/scheduling');
        break;
      case 3:
        context.go('/settings/push-notification');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _getCurrentIndex(context),
        onItemTapped: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
