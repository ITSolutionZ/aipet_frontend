import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../../home/data/providers/home_providers.dart';
import '../widgets/section_header_widget.dart';
import '../widgets/settings_tile_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: SoftGradientDrawerAppBar(
        title: '設定',
        selectedPetInfo: Container(
          margin: const EdgeInsets.only(right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/placeholder.png',
              width: 35,
              height: 35,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 35,
                  height: 35,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 20),
                );
              },
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ユーザー情報カード
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 25),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ユーザ さん',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'test@test.com',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // アカウント
          const SectionHeaderWidget(title: 'アカウント'),
          SettingsTileWidget(
            icon: Icons.person,
            title: 'プロフィール編集',
            backgroundColor: const Color(0xFFA88B5A),
            onTap: () => context.push(AppRouter.profileEditRoute),
          ),
          SettingsTileWidget(
            icon: Icons.pets,
            title: 'ペット情報編集',
            backgroundColor: const Color(0xFFA88B5A),
            onTap: () {
              // 현재 선택된 펫의 ID를 가져오거나 기본값 사용
              final selectedPet = ref.read(homeSelectedPetNotifierProvider);
              final petId = selectedPet?.id ?? 'default';
              context.push('${AppRouter.petProfileRoute}?petId=$petId');
            },
          ),
          SettingsTileWidget(
            icon: Icons.lock,
            title: 'パスワード変更',
            backgroundColor: const Color(0xFFA88B5A),
            onTap: () {},
          ),
          SettingsTileWidget(
            icon: Icons.delete,
            title: 'アカウント削除',
            backgroundColor: const Color(0xFFB85A5A),
            onTap: () => context.push(AppRouter.accountDeleteRoute),
          ),

          const SizedBox(height: AppSpacing.lg),

          // システム
          const SectionHeaderWidget(title: 'システム'),
          SettingsTileWidget(
            icon: Icons.notifications,
            title: 'プッシュ通知',
            backgroundColor: const Color(0xFF7A9CC6),
            onTap: () => context.push(AppRouter.pushNotificationRoute),
          ),
          SettingsTileWidget(
            icon: Icons.star,
            title: 'プレミアム管理',
            backgroundColor: const Color(0xFF7A9CC6),
            onTap: () {},
          ),
          SettingsTileWidget(
            icon: Icons.lightbulb,
            title: 'テーマ設定',
            backgroundColor: const Color(0xFF7A9CC6),
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.lg),

          // その他
          const SectionHeaderWidget(title: 'その他'),
          SettingsTileWidget(
            icon: Icons.help,
            title: 'お問い合わせ',
            backgroundColor: const Color(0xFFB8A5A5),
            onTap: () {},
          ),
          SettingsTileWidget(
            icon: Icons.info,
            title: 'アプリ情報',
            backgroundColor: const Color(0xFFB8A5A5),
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
