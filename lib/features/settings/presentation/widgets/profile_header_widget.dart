import 'dart:io';

import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
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

  /// 사용자 프로필 이미지 위젯
  Widget _buildUserProfileImage(UserProfileState profileState) {
    // 프로필 이미지가 있으면 표시
    if (profileState.profile?.profileImage != null &&
        profileState.profile!.profileImage!.isNotEmpty) {
      return _buildProfileImageWidget(profileState.profile!.profileImage!);
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
  }

  /// 프로필 이미지 위젯 빌드 (이미지 타입 감지)
  Widget _buildProfileImageWidget(String imagePath) {
    final imageType = ImageService.getImageType(imagePath);

    switch (imageType) {
      case ImageType.file:
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultUserImage();
          },
        );
      case ImageType.network:
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultUserImage();
          },
        );
      case ImageType.asset:
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
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
