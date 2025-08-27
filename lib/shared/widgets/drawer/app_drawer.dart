import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFF56453F),
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            const DrawerHeaderWidget(),

            // 스크롤 가능한 콘텐츠
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Pet 섹션
                    PetSectionWidget(),

                    // Health 섹션
                    HealthSectionWidget(),

                    // Service 섹션
                    ServiceSectionWidget(),
                  ],
                ),
              ),
            ),

            // 로그아웃 버튼
            LogoutButtonWidget(
              onTap: () async {
                await _handleLogout(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 로그아웃 처리
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // 확인 다이얼로그 표시
      final shouldLogout = await UiService.showConfirmDialog(
        context,
        title: 'ログアウト',
        content: 'ログアウトしますか？',
        confirmText: 'ログアウト',
        cancelText: 'キャンセル',
      );

      if (!shouldLogout) return;

      // 로딩 다이얼로그 표시
      if (context.mounted) {
        UiService.showLoadingDialog(context, 'ログアウト中...');
      }

      // 로그아웃 처리 (목업 구현)
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션
      const isSuccess = true;
      const message = 'ログアウトされました';

      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        UiService.hideLoadingDialog(context);
      }

      // 드로어 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 결과에 따른 처리
      if (isSuccess && context.mounted) {
        UiService.showSuccess(context, message);
        // 로그인 화면으로 이동
        context.go('/login');
      } else {
        if (context.mounted) {
          UiService.showError(context, message);
        }
      }
    } catch (error) {
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        UiService.hideLoadingDialog(context);
        UiService.showError(context, 'ログアウト中にエラーが発生しました');
      }
    }
  }
}
