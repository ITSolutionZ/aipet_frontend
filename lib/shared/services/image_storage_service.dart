import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 🖼️ 단일 통합 이미지 저장소 서비스
///
/// 모든 이미지 (프로필, 펫, 일반)를 단일 위치에서 관리하며,
/// 절대 경로 대신 상대 경로를 사용하여 앱 재설치 시에도
/// 이미지 경로가 유효하게 유지됩니다.
class ImageStorageService {
  static final ImageStorageService _instance = ImageStorageService._internal();

  factory ImageStorageService() => _instance;

  ImageStorageService._internal();

  // 상수 정의
  static const String _imageDirectoryName = 'app_images';
  static const String _profileSubDir = 'profiles';
  static const String _petSubDir = 'pets';
  static const String _generalSubDir = 'general';

  Directory? _baseDirectory;

  /// 저장소 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _baseDirectory = Directory('${appDir.path}/$_imageDirectoryName');

      // 기본 디렉토리 생성
      if (!await _baseDirectory!.exists()) {
        await _baseDirectory!.create(recursive: true);
        debugPrint(
          '📁 ImageStorageService initialized: ${_baseDirectory!.path}',
        );
      }

      // 서브 디렉토리 생성
      await _ensureSubDirectory(_profileSubDir);
      await _ensureSubDirectory(_petSubDir);
      await _ensureSubDirectory(_generalSubDir);

      debugPrint('✅ ImageStorageService initialization completed');
    } catch (e) {
      debugPrint('❌ ImageStorageService initialization failed: $e');
      rethrow;
    }
  }

  /// 서브 디렉토리 생성 보장
  Future<void> _ensureSubDirectory(String subDir) async {
    final dir = Directory('${_baseDirectory!.path}/$subDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      debugPrint('📁 Created subdirectory: $subDir');
    }
  }

  /// 프로필 이미지 저장 (절대 경로 반환)
  Future<String?> saveProfileImage(File imageFile) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final relativePath = '$_profileSubDir/$fileName';
      return await _saveImage(imageFile, relativePath);
    } catch (e) {
      debugPrint('❌ Failed to save profile image: $e');
      return null;
    }
  }

  /// 펫 이미지 저장 (상대 경로 반환)
  Future<String?> savePetImage(File imageFile) async {
    try {
      debugPrint('🖼️ savePetImage 시작');
      debugPrint('  - Source file: ${imageFile.path}');
      debugPrint('  - File exists: ${await imageFile.exists()}');

      // ImageStorageService 초기화 확인
      if (_baseDirectory == null) {
        debugPrint(
          '⚠️ ImageStorageService not initialized, initializing now...',
        );
        await initialize();
      }

      final fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final relativePath = '$_petSubDir/$fileName';

      debugPrint('  - Target relative path: $relativePath');

      final savedPath = await _saveImage(imageFile, relativePath);

      if (savedPath != null) {
        debugPrint('✅ Pet image saved successfully');
        debugPrint('  - Saved path: $savedPath');
      } else {
        debugPrint('❌ Pet image save failed (null returned)');
      }

      return savedPath;
    } catch (e) {
      debugPrint('❌ Failed to save pet image: $e');
      return null;
    }
  }

  /// 일반 이미지 저장 (절대 경로 반환)
  Future<String?> saveGeneralImage(File imageFile) async {
    try {
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final relativePath = '$_generalSubDir/$fileName';
      return await _saveImage(imageFile, relativePath);
    } catch (e) {
      debugPrint('❌ Failed to save general image: $e');
      return null;
    }
  }

  /// 내부 이미지 저장 로직 (상대 경로 반환)
  Future<String?> _saveImage(File sourceFile, String relativePath) async {
    try {
      debugPrint('💾 _saveImage 시작');
      debugPrint('  - relativePath: $relativePath');

      if (_baseDirectory == null) {
        debugPrint('⚠️ ImageStorageService not initialized');
        return null;
      }

      final targetPath = '${_baseDirectory!.path}/$relativePath';
      debugPrint('  - targetPath: $targetPath');

      final targetFile = File(targetPath);

      // 대상 디렉토리 생성
      final targetDir = targetFile.parent;
      debugPrint('  - targetDir: ${targetDir.path}');

      if (!await targetDir.exists()) {
        debugPrint('  - Creating target directory...');
        await targetDir.create(recursive: true);
      }

      // 파일 복사
      debugPrint('  - Copying file...');
      final savedFile = await sourceFile.copy(targetPath);

      // 저장 확인
      if (await savedFile.exists()) {
        final fileSize = await savedFile.length();
        debugPrint('✅ Image saved successfully');
        debugPrint('   Absolute path: $targetPath');
        debugPrint('   Relative path: $relativePath');
        debugPrint('   Size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

        // ⚠️ 중요: 상대 경로 반환 (앱 재시작 시에도 유효)
        return relativePath;
      } else {
        debugPrint('❌ Failed to verify saved image');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error saving image: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// 상대 경로를 절대 경로로 변환
  String? getAbsolutePath(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      debugPrint('⚠️ getAbsolutePath: relativePath is null or empty');
      return null;
    }

    if (_baseDirectory == null) {
      debugPrint('⚠️ getAbsolutePath: _baseDirectory is null');
      return null;
    }

    // 이미 절대 경로인 경우 그대로 반환
    if (relativePath.startsWith('/')) {
      debugPrint('ℹ️ getAbsolutePath: Already absolute path: $relativePath');
      return relativePath;
    }

    // 상대 경로를 절대 경로로 변환
    final absolutePath = '${_baseDirectory!.path}/$relativePath';
    debugPrint('🔄 getAbsolutePath:');
    debugPrint('  - Relative: $relativePath');
    debugPrint('  - Absolute: $absolutePath');
    return absolutePath;
  }

  /// 이미지 존재 여부 확인
  Future<bool> imageExists(String imagePath) async {
    try {
      if (imagePath.isEmpty) return false;

      // 상대 경로인 경우 절대 경로로 변환
      final absolutePath = getAbsolutePath(imagePath) ?? imagePath;
      final file = File(absolutePath);
      return await file.exists();
    } catch (e) {
      debugPrint('⚠️ Error checking image existence: $e');
      return false;
    }
  }

  /// 이미지 삭제
  Future<bool> deleteImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) return false;

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Image deleted: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
      return false;
    }
  }

  /// 기본 디렉토리 경로 반환
  String? getBasePath() => _baseDirectory?.path;

  /// 저장소 상태 확인
  Future<void> printStorageStatus() async {
    try {
      if (_baseDirectory == null) {
        debugPrint('⚠️ ImageStorageService not initialized');
        return;
      }

      final baseDir = _baseDirectory!;
      debugPrint('\n=== ImageStorageService Status ===');
      debugPrint('Base Path: ${baseDir.path}');
      debugPrint('Exists: ${await baseDir.exists()}');

      // 각 서브 디렉토리 상태
      for (final subDir in [_profileSubDir, _petSubDir, _generalSubDir]) {
        final dir = Directory('${baseDir.path}/$subDir');
        final exists = await dir.exists();
        final files = exists ? await dir.list().length : 0;
        debugPrint('$subDir: ${exists ? "✅" : "❌"} ($files files)');
      }
      debugPrint('==================================\n');
    } catch (e) {
      debugPrint('⚠️ Error printing storage status: $e');
    }
  }

  /// 저장소 초기화 (모든 이미지 삭제)
  Future<bool> clearAllImages() async {
    try {
      if (_baseDirectory == null) {
        debugPrint('⚠️ ImageStorageService not initialized');
        return false;
      }

      if (await _baseDirectory!.exists()) {
        await _baseDirectory!.delete(recursive: true);
        // 다시 생성
        await initialize();
        debugPrint('✅ All images cleared and storage reinitialized');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error clearing storage: $e');
      return false;
    }
  }
}
