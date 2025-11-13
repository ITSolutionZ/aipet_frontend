import 'dart:io';

import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basic_info/controllers/pet_basic_info_controller.dart';

/// Pet 이미지 처리 헬퍼
class PetInfoImageHelper {
  /// 이미지 위젯 빌드 - 강화된 로컬 저장 지원
  static Widget buildImageWidget(String imagePath) {
    LoggerService.debug('🖼️ buildImageWidget - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    LoggerService.debug('🖼️ absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    LoggerService.debug('🖼️ imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        LoggerService.debug('🖼️ File exists: $fileExists');

        if (!fileExists) {
          LoggerService.debug('❌ File does not exist: $absolutePath');
          // 백업에서 복원 시도
          return _buildImageWithBackup(imagePath);
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ Image.file error: $error');
            return _buildErrorWidget(context, error, stackTrace);
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ Image.network error: $error');
            return _buildErrorWidget(context, error, stackTrace);
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('🖼️ Image.asset error: $error');
            return _buildErrorWidget(context, error, stackTrace);
          },
        );
    }
  }

  /// 백업에서 이미지 복원 시도
  static Widget _buildImageWithBackup(String originalPath) {
    return FutureBuilder<List<String>>(
      future: ImageService.loadPetImagePaths(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // 가장 최근 이미지 사용
          final latestImagePath = snapshot.data!.last;
          LoggerService.debug('🔄 Using backup image: $latestImagePath');

          final file = File(latestImagePath);
          if (file.existsSync()) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorWidget(context, error, stackTrace);
              },
            );
          }
        }

        // 백업도 없으면 에러 위젯 표시
        return _buildErrorWidget(null, 'No backup found', null);
      },
    );
  }

  /// 에러 위젯 빌드
  static Widget _buildErrorWidget(
    BuildContext? context,
    Object error,
    StackTrace? stackTrace,
  ) {
    LoggerService.debug('🖼️ Building error widget for: $error');
    return Container(
      color: AppColors.pointOffWhite,
      child: Image.asset(
        'assets/icons/logos/aipet_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.pets, size: 40, color: AppColors.pointGray);
        },
      ),
    );
  }

  /// 프로필 이미지 변경 모달 표시
  static void showChangeProfileImageModal(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String petId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(context);
                pickImageFromCamera(context, ref, tabId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                pickImageFromGallery(context, ref, tabId);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 카메라에서 이미지 선택
  static Future<void> pickImageFromCamera(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) async {
    final imagePath = await ImageService.pickFromCamera(context);
    if (imagePath != null && context.mounted) {
      ref
          .read(petBasicInfoControllerProvider(tabId).notifier)
          .updateSelectedImage(imagePath);
      SnackBarService.showSuccess(context, '写真が選択されました');
    }
  }

  /// 갤러리에서 이미지 선택
  static Future<void> pickImageFromGallery(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) async {
    final imagePath = await ImageService.pickFromGallery(context);
    LoggerService.debug('📸 Selected image path: $imagePath');

    if (imagePath != null && context.mounted) {
      // ファイルが実際に存在するか確認
      final file = File(imagePath);
      final exists = file.existsSync();
      LoggerService.debug('📸 File exists: $exists');

      ref
          .read(petBasicInfoControllerProvider(tabId).notifier)
          .updateSelectedImage(imagePath);
      SnackBarService.showSuccess(context, '画像が選択されました');
    }
  }
}
