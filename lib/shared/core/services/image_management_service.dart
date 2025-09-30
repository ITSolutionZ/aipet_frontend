import 'dart:io';
import 'dart:typed_data';

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// 이미지 선택 소스 열거형
enum ImagePickerSource { camera, gallery }

/// 이미지 관리 서비스
///
/// 이미지 선택, 압축, 저장, 삭제 등의 기능을 제공합니다.
class ImageManagementService {
  final ImagePicker _imagePicker = ImagePicker();
  final Logger _logger = Logger();

  static final ImageManagementService _instance = ImageManagementService._internal();
  factory ImageManagementService() => _instance;
  ImageManagementService._internal();

  /// 이미지 품질 설정
  static const int _imageQuality = 85;
  static const int _maxWidth = 1024;
  static const int _maxHeight = 1024;

  /// 갤러리에서 이미지 선택
  Future<Result<File?>> pickImageFromGallery({
    bool compress = true,
    int? imageQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: compress ? (imageQuality ?? _imageQuality) : null,
        maxWidth: compress ? (maxWidth ?? _maxWidth).toDouble() : null,
        maxHeight: compress ? (maxHeight ?? _maxHeight).toDouble() : null,
      );

      if (image == null) {
        return Result.success('이미지 선택이 취소되었습니다', null);
      }

      final File imageFile = File(image.path);
      return Result.success('이미지가 성공적으로 선택되었습니다', imageFile);
    } catch (error) {
      _logger.e('갤러리 이미지 선택 실패', error: error);
      return Result.failure('갤러리에서 이미지를 선택하는데 실패했습니다: ${error.toString()}');
    }
  }

  /// 카메라로 이미지 촬영
  Future<Result<File?>> takePhotoWithCamera({
    bool compress = true,
    int? imageQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: compress ? (imageQuality ?? _imageQuality) : null,
        maxWidth: compress ? (maxWidth ?? _maxWidth).toDouble() : null,
        maxHeight: compress ? (maxHeight ?? _maxHeight).toDouble() : null,
      );

      if (image == null) {
        return Result.success('사진 촬영이 취소되었습니다', null);
      }

      final File imageFile = File(image.path);
      return Result.success('사진이 성공적으로 촬영되었습니다', imageFile);
    } catch (error) {
      _logger.e('카메라 사진 촬영 실패', error: error);
      return Result.failure('카메라로 사진을 촬영하는데 실패했습니다: ${error.toString()}');
    }
  }

  /// 여러 이미지 선택 (갤러리만)
  Future<Result<List<File>>> pickMultipleImages({
    int maxImages = 5,
    bool compress = true,
    int? imageQuality,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: compress ? (imageQuality ?? _imageQuality) : null,
        maxWidth: compress ? _maxWidth.toDouble() : null,
        maxHeight: compress ? _maxHeight.toDouble() : null,
      );

      if (images.isEmpty) {
        return Result.success('이미지 선택이 취소되었습니다', []);
      }

      if (images.length > maxImages) {
        return Result.failure('최대 $maxImages개의 이미지만 선택할 수 있습니다');
      }

      final List<File> imageFiles = images.map((xFile) => File(xFile.path)).toList();
      return Result.success('${imageFiles.length}개의 이미지가 선택되었습니다', imageFiles);
    } catch (error) {
      _logger.e('다중 이미지 선택 실패', error: error);
      return Result.failure('이미지들을 선택하는데 실패했습니다: ${error.toString()}');
    }
  }

  /// 이미지를 앱 디렉토리에 저장
  Future<Result<String>> saveImageToAppDirectory(File imageFile, {String? fileName}) async {
    try {
      final Directory appDocumentDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDocumentDir.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = imageFile.path.split('.').last;
      final String finalFileName = fileName ?? 'image_$timestamp.$extension';

      final String savedPath = '${imagesDir.path}/$finalFileName';
      final File savedFile = await imageFile.copy(savedPath);

      return Result.success('이미지가 성공적으로 저장되었습니다', savedFile.path);
    } catch (error) {
      _logger.e('이미지 저장 실패', error: error);
      return Result.failure('이미지 저장에 실패했습니다: ${error.toString()}');
    }
  }

  /// 저장된 이미지 삭제
  Future<Result<void>> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        return Result.failure('삭제할 이미지 파일이 존재하지 않습니다');
      }

      await imageFile.delete();
      return Result.success('이미지가 성공적으로 삭제되었습니다', null);
    } catch (error) {
      _logger.e('이미지 삭제 실패', error: error);
      return Result.failure('이미지 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  /// 이미지 파일 크기 확인 (바이트)
  Future<Result<int>> getImageSize(String imagePath) async {
    try {
      final File imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        return Result.failure('이미지 파일이 존재하지 않습니다');
      }

      final int size = await imageFile.length();
      return Result.success('이미지 크기를 확인했습니다', size);
    } catch (error) {
      _logger.e('이미지 크기 확인 실패', error: error);
      return Result.failure('이미지 크기 확인에 실패했습니다: ${error.toString()}');
    }
  }

  /// 이미지를 Uint8List로 읽기 (메모리에 로드)
  Future<Result<Uint8List>> readImageAsBytes(String imagePath) async {
    try {
      final File imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        return Result.failure('이미지 파일이 존재하지 않습니다');
      }

      final Uint8List bytes = await imageFile.readAsBytes();
      return Result.success('이미지를 메모리에 로드했습니다', bytes);
    } catch (error) {
      _logger.e('이미지 바이트 읽기 실패', error: error);
      return Result.failure('이미지 읽기에 실패했습니다: ${error.toString()}');
    }
  }

  /// 앱 내 저장된 모든 이미지 목록 조회
  Future<Result<List<String>>> getAllSavedImages() async {
    try {
      final Directory appDocumentDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDocumentDir.path}/images');

      if (!await imagesDir.exists()) {
        return Result.success('저장된 이미지가 없습니다', []);
      }

      final List<FileSystemEntity> entities = await imagesDir.list().toList();
      final List<String> imagePaths = entities
          .whereType<File>()
          .where((file) => _isImageFile(file.path))
          .map((file) => file.path)
          .toList();

      imagePaths.sort((a, b) => File(b).lastModifiedSync().compareTo(File(a).lastModifiedSync()));

      return Result.success('${imagePaths.length}개의 이미지를 찾았습니다', imagePaths);
    } catch (error) {
      _logger.e('저장된 이미지 목록 조회 실패', error: error);
      return Result.failure('저장된 이미지 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// 이미지 캐시 정리 (오래된 임시 이미지 삭제)
  Future<Result<int>> cleanImageCache({int maxAgeInDays = 30}) async {
    try {
      final Directory appDocumentDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDocumentDir.path}/images');

      if (!await imagesDir.exists()) {
        return Result.success('정리할 이미지가 없습니다', 0);
      }

      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));
      final List<FileSystemEntity> entities = await imagesDir.list().toList();

      int deletedCount = 0;
      for (final entity in entities) {
        if (entity is File && _isImageFile(entity.path)) {
          final DateTime lastModified = await entity.lastModified();
          if (lastModified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      return Result.success('$deletedCount개의 오래된 이미지를 정리했습니다', deletedCount);
    } catch (error) {
      _logger.e('이미지 캐시 정리 실패', error: error);
      return Result.failure('이미지 캐시 정리에 실패했습니다: ${error.toString()}');
    }
  }

  /// 이미지 압축 (기존 파일 덮어쓰기)
  Future<Result<String>> compressImage(
    String imagePath, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final File originalFile = File(imagePath);

      if (!await originalFile.exists()) {
        return Result.failure('압축할 이미지 파일이 존재하지 않습니다');
      }

      // 임시로 새 이름으로 압축된 이미지 생성
      final String directory = originalFile.parent.path;
      final String fileName = originalFile.path.split('/').last;

      final XFile? compressedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
      );

      if (compressedImage == null) {
        return Result.failure('이미지 압축에 실패했습니다');
      }

      // 원본 파일 삭제 후 압축된 파일을 원본 경로로 이동
      await originalFile.delete();
      final File finalFile = await File(compressedImage.path).copy(imagePath);

      return Result.success('이미지가 성공적으로 압축되었습니다', finalFile.path);
    } catch (error) {
      _logger.e('이미지 압축 실패', error: error);
      return Result.failure('이미지 압축에 실패했습니다: ${error.toString()}');
    }
  }

  /// 이미지 파일 확장자 검증
  bool _isImageFile(String path) {
    final String extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// 이미지 경로에서 파일명 추출
  String getFileNameFromPath(String path) {
    return path.split('/').last;
  }

  /// 이미지 파일 확장자 추출
  String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// 이미지 저장 디렉토리 경로 가져오기
  Future<String> getImageStorageDirectory() async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    return '${appDocumentDir.path}/images';
  }

  /// 전체 이미지 저장소 크기 계산 (바이트)
  Future<Result<int>> getTotalStorageSize() async {
    try {
      final Result<List<String>> allImagesResult = await getAllSavedImages();

      if (!allImagesResult.isSuccess) {
        return Result.failure(allImagesResult.error?.toString() ?? '저장된 이미지 목록 조회에 실패했습니다');
      }

      int totalSize = 0;
      for (final String imagePath in allImagesResult.dataOrNull!) {
        final Result<int> sizeResult = await getImageSize(imagePath);
        if (sizeResult.isSuccess) {
          totalSize += sizeResult.dataOrNull!;
        }
      }

      return Result.success('총 저장소 크기를 계산했습니다', totalSize);
    } catch (error) {
      _logger.e('저장소 크기 계산 실패', error: error);
      return Result.failure('저장소 크기 계산에 실패했습니다: ${error.toString()}');
    }
  }

  /// 이미지 파일명 생성 (타임스탬프 기반)
  String generateImageFileName({String prefix = 'image', String extension = 'jpg'}) {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${prefix}_$timestamp.$extension';
  }

  /// 이미지 파일이 유효한지 검증
  Future<Result<bool>> validateImageFile(String imagePath) async {
    try {
      final File imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        return Result.failure('이미지 파일이 존재하지 않습니다');
      }

      if (!_isImageFile(imagePath)) {
        return Result.failure('지원되지 않는 이미지 형식입니다');
      }

      final int size = await imageFile.length();
      if (size == 0) {
        return Result.failure('이미지 파일이 손상되었습니다');
      }

      // 최대 파일 크기 검증 (10MB)
      const int maxSizeInBytes = 10 * 1024 * 1024;
      if (size > maxSizeInBytes) {
        return Result.failure('이미지 파일이 너무 큽니다 (최대 10MB)');
      }

      return Result.success('유효한 이미지 파일입니다', true);
    } catch (error) {
      _logger.e('이미지 파일 검증 실패', error: error);
      return Result.failure('이미지 파일 검증에 실패했습니다: ${error.toString()}');
    }
  }
}
