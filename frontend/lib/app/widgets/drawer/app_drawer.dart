import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/pet_profile/presentation/widgets/drawer/pet_card_section_widget.dart';
import '../../../features/settings/presentation/widgets/drawer/drawer_header_widget.dart';
import '../../../shared/shared.dart';
import 'drawer_controller.dart' as drawer_ctrl;
import 'logout_button_widget.dart';
import 'service_inquiry_section_widget.dart';

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

    // 실제 사용자 프로필 데이터 가져오기 (TODO: implement userProfileControllerProvider)
    // final profileState = ref.watch(userProfileControllerProvider);

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
            userImagePath: null,
          ), // TODO: pass actual profile image
          // スクロール可能なコンテンツ
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // 情報バナー
                  // const DrawerInfoBannerWidget(),
                  const SizedBox(height: 16),

                  // ペットカードセクション
                  const PetCardSectionWidget(),
                  const SizedBox(height: 24),

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
              // 확인 다이얼로그 표시
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ログアウト'),
                  content: const Text('ログアウトしますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('ログアウト'),
                    ),
                  ],
                ),
              );

              // 확인된 경우에만 로그아웃 실행
              if (confirmed == true && context.mounted) {
                final controller = drawer_ctrl.DrawerController(ref);
                await controller.logout(context);
              }
            },
          ),

          // 下部余白（ホームインジケーター分）
          SizedBox(height: bottomPadding > 0 ? bottomPadding + 8 : 16),
        ],
      ),
    );
  }
}
