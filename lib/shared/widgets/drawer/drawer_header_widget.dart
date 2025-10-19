import 'dart:io';

import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ドロワーヘッダーウィジェット
/// プロフィール情報と統計を表示
class DrawerHeaderWidget extends ConsumerWidget {
  final String? userImagePath;

  const DrawerHeaderWidget({super.key, this.userImagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실제 사용자 프로필 가져오기
    final profileState = ref.watch(userProfileControllerProvider);
    final userStats = DrawerLocalDatasource.getUserStats();

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
                  border: Border.all(color: Colors.white, width: 2),
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
                    color: Colors.white,
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
              _StatItem(
                label: '購読',
                value: userStats['subscriptions'].toString(),
              ),
              _StatItem(label: '投稿', value: userStats['posts'].toString()),
              _StatItem(label: 'コメント', value: userStats['comments'].toString()),
              // 位置設定ボタン
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // ドロワーを閉じる
                  context.push(RouteConstants.locationSettingRoute);
                },
                child: const Column(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 18),
                    SizedBox(height: 2),
                    Text(
                      '位置設定',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
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

    debugPrint('🖼️ DrawerHeaderWidget - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    debugPrint('🖼️ DrawerHeaderWidget - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    debugPrint('🖼️ DrawerHeaderWidget - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        debugPrint('🖼️ DrawerHeaderWidget - File exists: $fileExists');

        if (!fileExists) {
          debugPrint(
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
            debugPrint('🖼️ DrawerHeaderWidget - File image error: $error');
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
            debugPrint('🖼️ DrawerHeaderWidget - Network image error: $error');
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
            debugPrint('🖼️ DrawerHeaderWidget - Asset image error: $error');
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

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}
