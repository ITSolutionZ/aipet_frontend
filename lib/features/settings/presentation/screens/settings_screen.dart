import 'dart:io';

import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
import 'package:aipet_frontend/features/settings/presentation/widgets/settings_tile_widget.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: SoftGradientDrawerAppBar(
        title: '設定',
        selectedPetInfo: Container(
          margin: const EdgeInsets.only(right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildUserProfileImage(profileState),
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
                  child: _buildUserProfileImage(profileState, size: 50),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profileState.profile?.userName ?? 'ユーザー'} さん',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      profileState.profile?.email ?? 'test@test.com',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
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
              // ペットプロフィール画面へ移動
              context.push('${AppRouter.petProfileRoute}?petId=default');
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
            title: '',
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
            icon: Icons.dashboard,
            title: 'データベースダッシュボード (開発用)',
            backgroundColor: const Color(0xFF6B73FF),
            onTap: () => context.push('/settings/database-dashboard'),
          ),
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

  /// 사용자 프로필 이미지 위젯
  Widget _buildUserProfileImage(
    UserProfileState profileState, {
    double size = 35,
  }) {
    // 프로필 이미지가 있으면 표시
    if (profileState.profile?.profileImage != null &&
        profileState.profile!.profileImage!.isNotEmpty) {
      return _buildProfileImageWidget(
        profileState.profile!.profileImage!,
        size: size,
      );
    }

    // 기본 이미지 표시
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logos/aipet_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.6,
              color: AppColors.pointGray.withValues(alpha: 0.7),
            );
          },
        ),
      ),
    );
  }

  /// 프로필 이미지 위젯 빌드 (이미지 타입 감지)
  Widget _buildProfileImageWidget(String imagePath, {double size = 35}) {
    final imageType = ImageService.getImageType(imagePath);

    switch (imageType) {
      case ImageType.file:
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultUserImage(size);
          },
        );
      case ImageType.network:
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultUserImage(size);
          },
        );
      case ImageType.asset:
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultUserImage(size);
          },
        );
    }
  }

  /// 기본 사용자 이미지 위젯
  Widget _buildDefaultUserImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logos/aipet_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.6,
              color: AppColors.pointGray.withValues(alpha: 0.7),
            );
          },
        ),
      ),
    );
  }
}
