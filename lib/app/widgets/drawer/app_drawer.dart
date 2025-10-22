import 'package:aipet_frontend/features/pet_profile/presentation/widgets/widgets.dart';
import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
import 'package:aipet_frontend/features/settings/presentation/widgets/settings_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'drawer_controller.dart';
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

    // 실제 사용자 프로필 데이터 가져오기
    final profileState = ref.watch(userProfileControllerProvider);

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: AppColors.pointBlue,
      child: Column(
        children: [
          // 上部パディング（ステータスバー分）
          SizedBox(height: topPadding),

          // ヘッダー（プロフィール情報）
          DrawerHeaderWidget(userImagePath: profileState.profile?.profileImage),

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
