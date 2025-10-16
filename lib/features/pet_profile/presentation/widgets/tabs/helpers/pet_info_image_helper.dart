import 'dart:io';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pet_basic_info_tab.dart';

/// Pet 이미지 처리 헬퍼
class PetInfoImageHelper {
  /// 이미지 위젯 빌드
  static Widget buildImageWidget(String imagePath) {
    final imageType = ImageService.getImageType(imagePath);

    switch (imageType) {
      case ImageType.file:
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: _buildErrorWidget,
        );
      case ImageType.network:
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: _buildErrorWidget,
        );
      case ImageType.asset:
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: _buildErrorWidget,
        );
    }
  }

  /// 에러 위젯 빌드
  static Widget _buildErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
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
          .read(petBasicInfoTabProvider(tabId).notifier)
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
    if (imagePath != null && context.mounted) {
      ref
          .read(petBasicInfoTabProvider(tabId).notifier)
          .updateSelectedImage(imagePath);
      SnackBarService.showSuccess(context, '画像が選択されました');
    }
  }
}
