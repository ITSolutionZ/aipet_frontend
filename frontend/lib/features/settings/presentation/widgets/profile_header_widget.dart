import 'dart:io';

import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileHeaderWidget extends ConsumerWidget {
  final String userName;
  final String email;
  final bool isEditable;

  const ProfileHeaderWidget({
    super.key,
    required this.userName,
    required this.email,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileControllerProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _buildUserProfileImage(profileState),
                ),
              ),
              if (isEditable)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.pointBrown,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointBrown,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text(
                'さん',
                style: TextStyle(fontSize: 16, color: AppColors.pointBrown),
              ),
            ],
          ),
          Text(email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  /// 사용자 프로필 이미지 위젯 - 강화된 로컬 저장 지원
  Widget _buildUserProfileImage(UserProfileState profileState) {
    // 프로필 이미지가 있으면 표시
    if (profileState.profile?.profileImage != null &&
        profileState.profile!.profileImage!.isNotEmpty) {
      return _buildProfileImageWidget(profileState.profile!.profileImage!);
    }

    // SharedPreferences에서 저장된 이미지 경로 확인
    return FutureBuilder<String?>(
      future: ImagePickerService().loadUserProfileImagePath(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          LoggerService.debug(
            '🖼️ ProfileHeaderWidget - Loading from preferences: ${snapshot.data}',
          );
          return _buildProfileImageWidget(snapshot.data!);
        }

        // 기본 이미지 표시
        return Image.asset(
          'assets/icons/logos/aipet_logo.png',
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 50),
            );
          },
        );
      },
    );
  }

  /// 프로필 이미지 위젯 빌드 (이미지 타입 감지)
  Widget _buildProfileImageWidget(String imagePath) {
    LoggerService.debug('🖼️ ProfileHeaderWidget - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    LoggerService.debug('🖼️ ProfileHeaderWidget - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ ProfileHeaderWidget - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        // ファイルが存在するかチェック
        final file = File(absolutePath);
        LoggerService.debug(
          '🖼️ ProfileHeaderWidget - File exists: ${file.existsSync()}',
        );

        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ ProfileHeaderWidget - File image error: $error');
            return _buildDefaultUserImage();
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ ProfileHeaderWidget - Network image error: $error');
            return _buildDefaultUserImage();
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ ProfileHeaderWidget - Asset image error: $error');
            return _buildDefaultUserImage();
          },
        );
    }
  }

  /// 기본 사용자 이미지 위젯
  Widget _buildDefaultUserImage() {
    return Image.asset(
      'assets/icons/logos/aipet_logo.png',
      fit: BoxFit.cover,
      width: 100,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey[300],
          child: const Icon(Icons.person, size: 50),
        );
      },
    );
  }
}
