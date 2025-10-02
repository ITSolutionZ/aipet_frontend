import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              final controller = ref.read(drawerControllerProvider);
              await controller.logout(context);
            },
          ),

          // 下部余白（ホームインジケーター分）
          SizedBox(height: bottomPadding > 0 ? bottomPadding + 8 : 16),
        ],
      ),
    );
  }
}
