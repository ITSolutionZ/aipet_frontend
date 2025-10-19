import 'dart:io';

import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 이미지 선택 서비스
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();
  final ImageStorageService _storageService = ImageStorageService();

  /// 카메라에서 이미지 선택
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('카메라에서 이미지 선택 실패: $e');
      return null;
    }
  }

  /// 갤러리에서 이미지 선택
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('갤러리에서 이미지 선택 실패: $e');
      return null;
    }
  }

  /// 이미지 선택 옵션 다이얼로그 표시
  Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'プロフィール画像を選択',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'カメラ',
                    onTap: () async {
                      return pickImageFromCamera();
                    },
                  ),
                  _buildImageSourceOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'ギャラリー',
                    onTap: () async {
                      return pickImageFromGallery();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Future<File?> Function() onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await onTap();
        if (context.mounted) {
          Navigator.pop(context, result);
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지를 앱 디렉토리에 저장 (프로필 이미지용)
  ///
  /// [imageFile] - 저장할 이미지 파일
  /// [fileName] - 파일명 (사용되지 않음, ImageStorageService에서 자동 생성)
  Future<String?> saveImageToAppDirectory(
    File imageFile, [
    String? fileName,
  ]) async {
    try {
      debugPrint('📸 Saving profile image using ImageStorageService');
      final savedPath = await _storageService.saveProfileImage(imageFile);
      if (savedPath != null) {
        debugPrint('✅ Profile image saved successfully: $savedPath');
      }
      return savedPath;
    } catch (e) {
      debugPrint('❌ 이미지 저장 실패: $e');
      return null;
    }
  }

  /// 이미지 파일 삭제
  Future<bool> deleteImage(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('이미지 삭제 실패: $e');
      return false;
    }
  }

  /// 이미지 파일 존재 확인
  Future<bool> imageExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
