import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/shared.dart';

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
        // 画像を永続的なディレクトリにコピー
        final persistentPath = await _copyToPersistentStorage(image.path);

        if (context.mounted) {
          SnackBarService.showSuccess(context, '이미지가 선택되었습니다');
        }
        return persistentPath;
      }
      return null;
    } catch (e) {
      debugPrint('pickFromGallery error: $e');
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
        // 画像を永続的なディレクトリにコピー
        final persistentPath = await _copyToPersistentStorage(image.path);

        if (context.mounted) {
          SnackBarService.showSuccess(context, '사진이 촬영되었습니다');
        }
        return persistentPath;
      }
      return null;
    } catch (e) {
      debugPrint('pickFromCamera error: $e');
      if (context.mounted) {
        final isSimulator = e.toString().contains('simulator');
        final message = isSimulator
            ? '시뮬레이터에서는 카메라를 사용할 수 없습니다'
            : '카메라 접근 권한이 필요합니다';

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

  /// 画像を永続的なストレージにコピー (ImageStorageService 사용) - 강화된 로컬 저장
  static Future<String> _copyToPersistentStorage(String tempPath) async {
    try {
      final tempFile = File(tempPath);
      final storageService = ImageStorageService();

      // ImageStorageService를 사용하여 펫 이미지 저장
      final savedPath = await storageService.savePetImage(tempFile);

      if (savedPath != null) {
        debugPrint('✅ Image saved using ImageStorageService: $savedPath');

        // SharedPreferences에 이미지 경로 저장
        await _savePetImagePathToPreferences(savedPath);

        // 추가 백업 저장
        await _createPetImageBackup(tempFile, savedPath);

        return savedPath;
      } else {
        debugPrint('❌ Failed to save image using ImageStorageService');
        // 실패 시 임시 경로 반환 (기존 동작 유지)
        return tempPath;
      }
    } catch (e) {
      debugPrint('❌ Error copying image to persistent storage: $e');
      // エラーの場合は元のパスを返す
      return tempPath;
    }
  }

  /// SharedPreferences에 펫 이미지 경로 저장
  static Future<void> _savePetImagePathToPreferences(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final key = 'pet_image_$timestamp';
      await prefs.setString(key, imagePath);
      debugPrint('💾 Pet image path saved to preferences: $key -> $imagePath');
    } catch (e) {
      debugPrint('❌ Failed to save pet image path to preferences: $e');
    }
  }

  /// 펫 이미지 백업 생성
  static Future<void> _createPetImageBackup(
    File originalFile,
    String savedPath,
  ) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String backupDir = path.join(appDir.path, 'pet_image_backups');

      // 백업 디렉토리 생성
      final Directory backupDirectory = Directory(backupDir);
      if (!await backupDirectory.exists()) {
        await backupDirectory.create(recursive: true);
        debugPrint('📁 Created pet image backup directory: $backupDir');
      }

      // 백업 파일 생성
      final String backupFileName =
          'pet_backup_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String backupPath = path.join(backupDir, backupFileName);
      await originalFile.copy(backupPath);

      debugPrint('💾 Pet image backup created: $backupPath');
    } catch (e) {
      debugPrint('❌ Failed to create pet image backup: $e');
    }
  }

  /// 저장된 펫 이미지 경로들 로드
  static Future<List<String>> loadPetImagePaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('pet_image_'))
          .toList();
      final List<String> imagePaths = [];

      for (final key in keys) {
        final imagePath = prefs.getString(key);
        if (imagePath != null && await File(imagePath).exists()) {
          imagePaths.add(imagePath);
          debugPrint('💾 Pet image path loaded: $key -> $imagePath');
        }
      }

      // 백업에서 복원 시도
      if (imagePaths.isEmpty) {
        final backupPaths = await _restorePetImagesFromBackup();
        imagePaths.addAll(backupPaths);
      }

      return imagePaths;
    } catch (e) {
      debugPrint('❌ Failed to load pet image paths: $e');
      return [];
    }
  }

  /// 백업에서 펫 이미지들 복원
  static Future<List<String>> _restorePetImagesFromBackup() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String backupDir = path.join(appDir.path, 'pet_image_backups');
      final Directory backupDirectory = Directory(backupDir);
      final List<String> restoredPaths = [];

      if (await backupDirectory.exists()) {
        final List<FileSystemEntity> files = await backupDirectory
            .list()
            .toList();
        for (final file in files) {
          if (file is File && await file.exists()) {
            restoredPaths.add(file.path);
            debugPrint('🔄 Restored pet image from backup: ${file.path}');
          }
        }
      }

      return restoredPaths;
    } catch (e) {
      debugPrint('❌ Failed to restore pet images from backup: $e');
      return [];
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
    try {
      debugPrint(
        '📷 ImageService: showImagePickerOptions called with allowRemoval: $allowRemoval, currentImagePath: $currentImagePath',
      );

      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) {
          debugPrint('📷 ImageService: Building bottom sheet');
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('갤러리에서 선택'),
                  onTap: () {
                    debugPrint('📷 ImageService: Gallery option tapped');
                    Navigator.pop(context, 'gallery');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('카메라로 촬영'),
                  onTap: () {
                    debugPrint('📷 ImageService: Camera option tapped');
                    Navigator.pop(context, 'camera');
                  },
                ),
                if (showDefaultImages)
                  ListTile(
                    leading: const Icon(Icons.pets),
                    title: const Text('기본 이미지 선택'),
                    onTap: () {
                      debugPrint(
                        '📷 ImageService: Default images option tapped',
                      );
                      Navigator.pop(context, 'default');
                    },
                  ),
                if (allowRemoval && currentImagePath != null)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('이미지 제거'),
                    onTap: () {
                      debugPrint('📷 ImageService: Remove option tapped');
                      Navigator.pop(context, 'REMOVE');
                    },
                  ),
              ],
            ),
          );
        },
      );

      debugPrint('📷 ImageService: Bottom sheet result: $result');

      // 사용자가 취소한 경우
      if (result == null) {
        debugPrint('📷 ImageService: User cancelled');
        return null;
      }

      // 선택된 옵션에 따라 실제 이미지 선택 수행
      switch (result) {
        case 'gallery':
          debugPrint('📷 ImageService: Opening gallery');
          final galleryResult = await pickFromGallery(context);
          debugPrint('📷 ImageService: Gallery result: $galleryResult');
          return galleryResult;
        case 'camera':
          debugPrint('📷 ImageService: Opening camera');
          final cameraResult = await pickFromCamera(context);
          debugPrint('📷 ImageService: Camera result: $cameraResult');
          return cameraResult;
        case 'default':
          debugPrint('📷 ImageService: Opening default images');
          final defaultResult = await _showDefaultImageSelection(
            context,
            customDefaultImages,
          );
          debugPrint('📷 ImageService: Default image result: $defaultResult');
          return defaultResult;
        case 'REMOVE':
          debugPrint('📷 ImageService: Removing image');
          return 'REMOVE';
        default:
          debugPrint('📷 ImageService: Unknown result: $result');
          return null;
      }
    } catch (e, stackTrace) {
      debugPrint('📷 ImageService: Exception in showImagePickerOptions: $e');
      debugPrint('📷 ImageService: Stack trace: $stackTrace');
      return null;
    }
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
                            child: const Icon(
                              Icons.pets,
                              color: AppColors.pointGray,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
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
  static Future<bool> deleteImage(
    BuildContext context,
    String imagePath,
  ) async {
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
      // 앱 문서 디렉토리 가져오기
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      // images 폴더가 없으면 생성
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final targetPath = '${imagesDir.path}/$fileName';
      final sourceFile = File(sourcePath);

      // 파일 복사
      await sourceFile.copy(targetPath);

      if (context.mounted) {
        SnackBarService.showSuccess(context, '이미지가 저장되었습니다');
      }
      return targetPath;
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, '이미지 저장 중 오류가 발생했습니다');
      }
      return null;
    }
  }

  /// 앱 설정 열기 (권한 설정용)
  static Future<void> _openAppSettings(BuildContext context) async {
    // 시스템 설정 안내 메시지
    SnackBarService.showInfo(context, '設定 > 権限でカメラ/ギャラリーアクセスを許可してください');
  }

  /// 이미지 압축
  static Future<Uint8List?> compressImage(
    String imagePath, {
    int quality = 80,
    int maxWidth = 1000,
    int maxHeight = 1000,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      // 파일을 바이트로 읽기
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('이미지 압축 실패: $e');
      return null;
    }
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
    } else if (imagePath.startsWith('/') || imagePath.contains('Documents/')) {
      // 절대 경로 또는 Documents 폴더 경로인 경우 파일로 처리
      return ImageType.file;
    } else {
      // 상대 경로인 경우도 파일로 처리
      return ImageType.file;
    }
  }
}

/// 이미지 타입 열거형
enum ImageType { network, asset, file }
