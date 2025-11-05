import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/notification/data/providers/notification_providers.dart';
import '../../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import '../../../../../../features/settings/presentation/controllers/user_profile_controller.dart';


/// ドロワーヘッダーウィジェット
/// プロフィール情報と統計を表示
class DrawerHeaderWidget extends ConsumerWidget {
  final String? userImagePath;

  const DrawerHeaderWidget({super.key, this.userImagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실제 사용자 프로필 가져오기
    final profileState = ref.watch(userProfileControllerProvider);

    // 실제 펫 데이터 가져오기
    final petsAsync = ref.watch(petProfilesProvider);

    // 미독 알림 수 가져오기
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

    // 프로필이 없으면 로드
    if (profileState.profile == null && !profileState.isLoading) {
      Future.microtask(() {
        ref.read(userProfileControllerProvider.notifier).loadProfile();
      });
    }

    // 사용자 이름과 이미지 경로 설정
    final userName = profileState.profile?.userName ?? 'ゲストユーザー';
    final profileImagePath =
        userImagePath ?? profileState.profile?.profileImage;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // アバター
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.pureWhite, width: 2),
                ),
                child: ClipOval(
                  child: _buildUserProfileImage(profileImagePath),
                ),
              ),
              const SizedBox(width: 16),
              // ユーザー名
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 統計情報と位置設定
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 펫 수 표시
              petsAsync.when(
                data: (pets) =>
                    _StatItem(label: 'ペット', value: pets.length.toString()),
                loading: () => const _StatItem(label: 'ペット', value: '...'),
                error: (_, __) => const _StatItem(label: 'ペット', value: '0'),
              ),
              // 산책 기록 수 (임시로 0)
              const _StatItem(label: '散歩', value: '0'),
              // 건강 기록 수 (임시로 0)
              const _StatItem(label: '健康', value: '0'),
              // 미독 알림 수 표시
              unreadCountAsync.when(
                data: (count) => _StatItem(
                  label: '未読',
                  value: count.toString(),
                  showBadge: count > 0,
                ),
                loading: () => const _StatItem(label: '未読', value: '...'),
                error: (_, __) => const _StatItem(label: '未読', value: '0'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 사용자 프로필 이미지 위젯 - 강화된 로컬 저장 지원
  Widget _buildUserProfileImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _buildDefaultUserImage();
    }

    LoggerService.debug('🖼️ DrawerHeaderWidget - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    LoggerService.debug('🖼️ DrawerHeaderWidget - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ DrawerHeaderWidget - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug('🖼️ DrawerHeaderWidget - File exists: $fileExists');

        if (!fileExists) {
          LoggerService.debug(
            '❌ DrawerHeaderWidget - File does not exist: $absolutePath',
          );
          return _buildDefaultUserImage();
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ DrawerHeaderWidget - File image error: $error');
            return _buildDefaultUserImage();
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ DrawerHeaderWidget - Network image error: $error');
            return _buildDefaultUserImage();
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ DrawerHeaderWidget - Asset image error: $error');
            return _buildDefaultUserImage();
          },
        );
    }
  }

  /// 기본 사용자 이미지
  Widget _buildDefaultUserImage() {
    return Image.asset(
      'assets/icons/logos/aipet_logo.png',
      fit: BoxFit.cover,
      width: 60,
      height: 60,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: const Icon(Icons.person, size: 30, color: Colors.grey),
        );
      },
    );
  }
}

/// 統計アイテムウィジェット
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool showBadge;

  const _StatItem({
    required this.label,
    required this.value,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.pureWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showBadge)
              Positioned(
                right: -8,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.pointRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Icon(
                    Icons.circle,
                    color: AppColors.pointRed,
                    size: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.pureWhite,
            fontSize: AppFonts.bodySmall.fontSize,
          ),
        ),
      ],
    );
  }
}
