import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// アプリドロワー
/// アプリ全体のナビゲーションとユーザー情報を提供
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: AppColors.pointBlue,
      child: Column(
        children: [
          // 上部パディング（ステータスバー分）
          SizedBox(height: topPadding),

          // ヘッダー（プロフィール情報）
          const DrawerHeaderWidget(
            userImagePath: null, // TODO: ユーザー画像パスを渡す
          ),

          // スクロール可能なコンテンツ
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // 情報バナー
                  const DrawerInfoBannerWidget(),
                  const SizedBox(height: 16),

                  // ペットカードセクション
                  const PetCardSectionWidget(),
                  const SizedBox(height: 24),

                  // マイブックマークセクション
                  const MyBookmarkSectionWidget(),
                  const SizedBox(height: 16),

                  // サービスお問い合わせセクション
                  const ServiceInquirySectionWidget(),
                  const SizedBox(height: 16),

                  // 下部余白（コンテンツ用）
                  SizedBox(height: bottomPadding + 100),
                ],
              ),
            ),
          ),

          // ログアウトボタン
          LogoutButtonWidget(
            onTap: () async {
              await _handleLogout(context, ref);
            },
          ),

          // 下部余白（ホームインジケーター分）
          SizedBox(height: bottomPadding > 0 ? bottomPadding + 8 : 16),
        ],
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
