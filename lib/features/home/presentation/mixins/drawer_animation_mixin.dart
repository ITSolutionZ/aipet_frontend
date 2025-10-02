import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ドロワーアニメーション機能を提供するMixin
///
/// ドロワーの開閉アニメーションを管理します。
mixin DrawerAnimationMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, TickerProviderStateMixin<T> {
  /// アニメーションコントローラー
  AnimationController? get drawerAnimationController;
  set drawerAnimationController(AnimationController? controller);

  /// スライドアニメーション
  Animation<Offset>? get drawerSlideAnimation;
  set drawerSlideAnimation(Animation<Offset>? animation);

  /// ドロワーの開閉状態
  bool get isDrawerOpen;
  set isDrawerOpen(bool value);

  /// ドロワーアニメーションを初期化
  void initDrawerAnimation() {
    drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    drawerSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: drawerAnimationController!,
            curve: Curves.easeInOut,
          ),
        );
  }

  /// ドロワーを開く
  void openDrawer(WidgetRef ref, {StateProvider<bool>? drawerStateProvider}) {
    if (mounted) {
      setState(() {
        isDrawerOpen = true;
      });
      // プロバイダーがあれば状態を更新
      if (drawerStateProvider != null) {
        ref.read(drawerStateProvider.notifier).state = true;
      }
      drawerAnimationController?.forward();
    }
  }

  /// ドロワーを閉じる
  void closeDrawer(WidgetRef ref, {StateProvider<bool>? drawerStateProvider}) {
    drawerAnimationController?.reverse().then((_) {
      if (mounted) {
        setState(() {
          isDrawerOpen = false;
        });
        // プロバイダーがあれば状態を更新
        if (drawerStateProvider != null) {
          ref.read(drawerStateProvider.notifier).state = false;
        }
      }
    });
  }

  /// ドロワーの開閉を切り替え
  void toggleDrawer(WidgetRef ref, {StateProvider<bool>? drawerStateProvider}) {
    if (isDrawerOpen) {
      closeDrawer(ref, drawerStateProvider: drawerStateProvider);
    } else {
      openDrawer(ref, drawerStateProvider: drawerStateProvider);
    }
  }

  /// アニメーションコントローラーを破棄
  void disposeDrawerAnimation() {
    drawerAnimationController?.dispose();
    drawerAnimationController = null;
  }
}
