import 'package:aipet_frontend/shared/providers/drawer_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'custom_bottom_navigation.dart';

class MainNavigationScreen extends ConsumerWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});
  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    // 홈에서 접근하는 라우트들은 선택 상태 없음
    if (location == '/walk-from-home') {
      return -1; // 선택된 탭 없음
    }

    if (location.startsWith('/home') || location.startsWith('/community')) {
      return 0; // 커뮤니티는 홈 탭에 포함
    } else if (location.startsWith('/ai')) {
      return 1;
    } else if (location.startsWith('/walk')) {
      return 2;
    } else if (location.startsWith('/scheduling')) {
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
        context.go('/walk');
        break;
      case 3:
        context.go('/scheduling');
        break;
      case 4:
        context.go('/settings');
        break;
      default:
        context.go('/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDrawerOpen = ref.watch(drawerStateProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: isDrawerOpen
          ? null // ドロワーが開いている時は非表示
          : CustomBottomNavigation(
              selectedIndex: _getCurrentIndex(context),
              onItemTapped: (index) => _onItemTapped(context, index),
            ),
    );
  }
}
