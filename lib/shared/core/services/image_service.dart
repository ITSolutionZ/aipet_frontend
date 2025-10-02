import 'dart:io';
import 'dart:typed_data';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 🖼️ 중앙화된 이미지 관리 서비스
///
/// 이미지 선택, 압축, 캐싱, 저장을 통합 관리하며,
/// 일관된 사용자 경험을 제공합니다.
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // 기본 이미지 품질 설정
  static const int _defaultImageQuality = 80;
  static const double _defaultMaxWidth = 1000;
  static const double _defaultMaxHeight = 1000;

  /// 갤러리에서 이미지 선택
  ///
  /// [context] - 스낵바 표시용 컨텍스트
  /// [maxWidth] - 최대 너비 (기본: 1000px)
  /// [maxHeight] - 최대 높이 (기본: 1000px)
  /// [imageQuality] - 압축 품질 (기본: 80)
  static Future<String?> pickFromGallery(
    BuildContext context, {
    double maxWidth = _defaultMaxWidth,
    double maxHeight = _defaultMaxHeight,
    int imageQuality = _defaultImageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        if (context.mounted) {
          SnackBarService.showSuccess(context, '이미지가 선택되었습니다');
        }
        return image.path;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showPermissionRequired(
          context,
          '갤러리 접근',
          onSettings: () => _openAppSettings(context),
        );
      }
      return null;
    }
  }

  /// 카메라에서 이미지 촬영
  ///
  /// [context] - 스낵바 표시용 컨텍스트
  /// [maxWidth] - 최대 너비 (기본: 1000px)
  /// [maxHeight] - 최대 높이 (기본: 1000px)
  /// [imageQuality] - 압축 품질 (기본: 80)
  static Future<String?> pickFromCamera(
    BuildContext context, {
    double maxWidth = _defaultMaxWidth,
    double maxHeight = _defaultMaxHeight,
    int imageQuality = _defaultImageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        if (context.mounted) {
          SnackBarService.showSuccess(context, '사진이 촬영되었습니다');
        }
        return image.path;
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        final isSimulator = e.toString().contains('simulator');
        final message = isSimulator ? '시뮬레이터에서는 카메라를 사용할 수 없습니다' : '카메라 접근 권한이 필요합니다';

        if (isSimulator) {
          SnackBarService.showWarning(context, message);
        } else {
          SnackBarService.showPermissionRequired(
            context,
            '카메라 접근',
            onSettings: () => _openAppSettings(context),
          );
        }
      }
      return null;
    }
  }

  /// 이미지 선택 옵션 표시
  ///
  /// 갤러리, 카메라, 기본 이미지 선택 옵션을 제공하는
  /// 통합 바텀시트를 표시합니다.
  static Future<String?> showImagePickerOptions(
    BuildContext context, {
    bool showDefaultImages = true,
    bool allowRemoval = false,
    List<String>? customDefaultImages,
    String? currentImagePath,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickFromGallery(context);
                  if (context.mounted && imagePath != null) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라로 촬영'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickFromCamera(context);
                  if (context.mounted && imagePath != null) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
              if (showDefaultImages)
                ListTile(
                  leading: const Icon(Icons.pets),
                  title: const Text('기본 이미지 선택'),
                  onTap: () async {
                    Navigator.pop(context);
                    final defaultImage = await _showDefaultImageSelection(
                      context,
                      customDefaultImages,
                    );
                    if (context.mounted && defaultImage != null) {
                      Navigator.pop(context, defaultImage);
                    }
                  },
                ),
              if (allowRemoval && currentImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('이미지 제거'),
                  onTap: () {
                    Navigator.pop(context, 'REMOVE');
                  },
                ),
            ],
          ),
        );
      },
    );

    return result;
  }

  /// 기본 이미지 선택 다이얼로그 표시
  static Future<String?> _showDefaultImageSelection(
    BuildContext context,
    List<String>? customImages,
  ) async {
    final defaultImages = customImages ?? _getDefaultPetImages();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('기본 이미지 선택'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: defaultImages.length,
              itemBuilder: (context, index) {
                final imagePath = defaultImages[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, imagePath);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                        color: AppColors.pointGray.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.pointGray.withValues(alpha: 0.2),
                            child: const Icon(Icons.pets, color: AppColors.pointGray),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소'))],
        );
      },
    );
  }

  /// 기본 펫 이미지 목록
  static List<String> _getDefaultPetImages() {
    return [
      'assets/images/pet_selector/dog.png',
      'assets/images/pet_selector/cat.png',
      'assets/images/dogs/shiba.png',
      'assets/images/dogs/poodle.jpg',
      'assets/images/dogs/pomeranian.png',
      'assets/images/dogs/dachshund.png',
      'assets/images/dogs/chiwawa.png',
      'assets/images/dogs/mixed.png',
      'assets/images/pet_selector/rabbit.png',
      'assets/images/pet_selector/bird.png',
      'assets/images/pet_selector/hamster.png',
      'assets/images/pet_selector/turtle.png',
    ];
  }

  /// 이미지 파일 크기 확인
  static Future<int> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// 이미지 파일 존재 여부 확인
  static Future<bool> imageExists(String imagePath) async {
    try {
      if (imagePath.startsWith('http')) {
        // 네트워크 이미지는 일단 true로 가정 (실제로는 HEAD 요청으로 확인 가능)
        return true;
      } else if (imagePath.startsWith('assets/')) {
        // 에셋 이미지는 빌드 시점에 확인되므로 true로 가정
        return true;
      } else {
        // 로컬 파일
        final file = File(imagePath);
        return await file.exists();
      }
    } catch (e) {
      return false;
    }
  }

  /// 이미지 삭제
  static Future<bool> deleteImage(BuildContext context, String imagePath) async {
    try {
      // 네트워크나 에셋 이미지는 삭제할 수 없음
      if (imagePath.startsWith('http') || imagePath.startsWith('assets/')) {
        SnackBarService.showWarning(context, '이 이미지는 삭제할 수 없습니다');
        return false;
      }

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        SnackBarService.showSuccess(context, '이미지가 삭제되었습니다');
        return true;
      } else {
        SnackBarService.showWarning(context, '삭제할 이미지를 찾을 수 없습니다');
        return false;
      }
    } catch (e) {
      SnackBarService.showError(context, '이미지 삭제 중 오류가 발생했습니다');
      return false;
    }
  }

  /// 이미지 복사 (임시 저장소에서 영구 저장소로)
  static Future<String?> copyImageToAppDirectory(
    BuildContext context,
    String sourcePath,
    String fileName,
  ) async {
    try {
      // TODO: 실제 앱 디렉토리 경로 구현 필요
      // final appDir = await getApplicationDocumentsDirectory();
      // final targetPath = '${appDir.path}/images/$fileName';

      // 현재는 Mock 구현
      if (context.mounted) {
        SnackBarService.showInfo(context, '이미지 저장 기능은 구현 예정입니다');
      }
      return sourcePath; // 임시로 원본 경로 반환
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, '이미지 저장 중 오류가 발생했습니다');
      }
      return null;
    }
  }

  /// 앱 설정 열기 (권한 설정용)
  static Future<void> _openAppSettings(BuildContext context) async {
    // TODO: 실제 설정 앱 열기 구현 필요
    // await openAppSettings();
    SnackBarService.showInfo(context, '설정 > 권한에서 카메라/갤러리 접근을 허용해주세요');
  }

  /// 이미지 압축 (추후 구현)
  static Future<Uint8List?> compressImage(
    String imagePath, {
    int quality = 80,
    int maxWidth = 1000,
    int maxHeight = 1000,
  }) async {
    // TODO: 이미지 압축 로직 구현
    return null;
  }

  /// 이미지 형식 검증
  static bool isValidImageFormat(String imagePath) {
    final supportedFormats = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final extension = imagePath.toLowerCase().split('.').last;
    return supportedFormats.any((format) => format.contains(extension));
  }

  /// 이미지 타입 결정 (네트워크/로컬/에셋)
  static ImageType getImageType(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return ImageType.network;
    } else if (imagePath.startsWith('assets/')) {
      return ImageType.asset;
    } else {
      return ImageType.file;
    }
  }
}

/// 이미지 타입 열거형
enum ImageType { network, asset, file }
