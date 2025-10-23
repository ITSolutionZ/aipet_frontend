import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../../../../shared/core/api/api_client.dart';
import '../../../../shared/core/data/result_types.dart';
import '../../../../shared/core/domain/common_errors.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/core/services/image_service.dart';
import '../../../../shared/core/services/secure_storage_service.dart';
import 'pet_api_service.dart';

enum ImageQuality {
  low, // 낮은 품질 (빠른 업로드)
  medium, // 중간 품질 (균형)
  high, // 높은 품질 (좋은 화질)
  original, // 원본 (압축 없음)
}

class PetImageUploadService {
  final PetApiService _petApiService;

  PetImageUploadService(this._petApiService);

  Future<ResultState<String>> uploadPetImage({
    required String petId,
    required File imageFile,
    ImageQuality quality = ImageQuality.medium,
    String? description,
    bool generateThumbnail = true,
  }) async {
    try {
      File processedImage = imageFile;

      if (quality != ImageQuality.original) {
        final processed = await _processImage(imageFile, quality);
        if (processed.isSuccess) {
          processedImage = processed.dataOrNull!;
        }
      }

      final uploadResult = await _petApiService.uploadPetImage(
        petId,
        processedImage,
        description: description,
      );

      if (uploadResult.isSuccess) {
        final response = uploadResult.dataOrNull!;

        await _cacheImageLocally(petId, response.imageUrl, processedImage);

        if (processedImage != imageFile) {
          await processedImage.delete();
        }

        return Success(response.imageUrl);
      }

      return ResultState.failure(
        uploadResult.errorOrNull ?? UnknownError(details: 'Upload failed'),
      );
    } catch (e) {
      return ResultState.failure(UnknownError.toString()));
    }
  }

  Future<ResultState<List<String>>> uploadMultiplePetImages({
    required String petId,
    required List<File> imageFiles,
    ImageQuality quality = ImageQuality.medium,
    List<String>? descriptions,
  }) async {
    try {
      final uploadedUrls = <String>[];

      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final description = descriptions != null && i < descriptions.length
            ? descriptions[i]
            : null;

        final uploadResult = await uploadPetImage(
          petId: petId,
          imageFile: imageFile,
          quality: quality,
          description: description,
        );

        if (uploadResult.isSuccess) {
          uploadedUrls.add(uploadResult.dataOrNull!);
        } else {
          return ResultState.failure(uploadResult.errorOrNull!);
        }
      }

      return Success(uploadedUrls);
    } catch (e) {
      return ResultState.failure(UnknownError.toString()));
    }
  }

  /// ✅ ImageService 사용으로 중복 제거
  Future<ResultState<File>> _processImage(
    File imageFile,
    ImageQuality quality,
  ) async {
    try {
      final jpegQuality = _getJpegQualityForQuality(quality);
      final maxDimension = _getMaxDimensionForQuality(quality);

      // ImageService를 사용하여 이미지 압축
      final compressedBytes = await ImageService.compressImage(
        imageFile.path,
        quality: jpegQuality,
        maxWidth: maxDimension,
        maxHeight: maxDimension,
      );

      if (compressedBytes == null) {
        return ResultState.failure(
          ValidationError(field: 'image', reason: '画像の処理に失敗しました'),
        );
      }

      // 압축된 이미지를 임시 파일로 저장
      final tempDir = Directory.systemTemp;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_processed.jpg';
      final processedFile = File(path.join(tempDir.path, fileName));

      await processedFile.writeAsBytes(compressedBytes);

      return Success(processedFile);
    } catch (e) {
      return ResultState.failure(UnknownError.toString()));
    }
  }

  int _getMaxDimensionForQuality(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 480;
      case ImageQuality.medium:
        return 800;
      case ImageQuality.high:
        return 1200;
      case ImageQuality.original:
        return 4000;
    }
  }

  int _getJpegQualityForQuality(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 70;
      case ImageQuality.medium:
        return 85;
      case ImageQuality.high:
        return 95;
      case ImageQuality.original:
        return 100;
    }
  }

  Future<void> _cacheImageLocally(
    String petId,
    String imageUrl,
    File imageFile,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      await SecureStorageService.setJson('cached_pet_images', {
        petId: {
          'url': imageUrl,
          'cached_at': DateTime.now().toIso8601String(),
          'size': imageBytes.length,
        },
      });
    } catch (e) {
      // 캐시 저장 실패는 무시 (메인 기능에 영향 없음)
    }
  }

  Future<ResultState<File?>> getCachedImage(String petId) async {
    try {
      final cachedImages = await SecureStorageService.getJson(
        'cached_pet_images',
      );
      if (cachedImages == null || !cachedImages.containsKey(petId)) {
        return const Success(null);
      }

      final imageData = cachedImages[petId] as Map<String, dynamic>?;
      if (imageData == null) {
        return const Success(null);
      }

      final cachedPath = imageData['local_path'] as String?;

      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          return Success(file);
        }
      }

      return const Success(null);
    } catch (e) {
      return ResultState.failure(
        CacheError('キャッシュ画像の取得に失敗しました', details: e.toString()),
      );
    }
  }

  Future<ResultState<void>> clearImageCache(String? petId) async {
    try {
      if (petId != null) {
        final cachedImages = await SecureStorageService.getJson(
          'cached_pet_images',
        );
        if (cachedImages != null && cachedImages.containsKey(petId)) {
          cachedImages.remove(petId);
          await SecureStorageService.setJson('cached_pet_images', cachedImages);
        }
      } else {
        await SecureStorageService.remove('cached_pet_images');
      }

      return const Success(null);
    } catch (e) {
      return ResultState.failure(
        CacheError('画像キャッシュの削除に失敗しました', details: e.toString()),
      );
    }
  }

  Future<ResultState<Map<String, dynamic>>> getImageMetadata(
    File imageFile,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return ResultState.failure(
          ValidationError(field: 'image', reason: '画像メタデータを読み取れません'),
        );
      }

      final metadata = {
        'width': image.width,
        'height': image.height,
        'size_bytes': bytes.length,
        'format': path.extension(imageFile.path).toLowerCase(),
        'aspect_ratio': image.width / image.height,
      };

      return Success(metadata);
    } catch (e) {
      return ResultState.failure(UnknownError.toString()));
    }
  }

  Future<ResultState<bool>> validateImageFile(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return ResultState.failure(
          ValidationError(field: 'image', reason: '画像ファイルが存在しません'),
        );
      }

      final extension = path.extension(imageFile.path).toLowerCase();
      const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

      if (!allowedExtensions.contains(extension)) {
        return ResultState.failure(
          ValidationError(field: 'image', reason: 'サポートされていない画像形式です'),
        );
      }

      final sizeBytes = await imageFile.length();
      const maxSizeBytes = 10 * 1024 * 1024; // 10MB

      if (sizeBytes > maxSizeBytes) {
        return ResultState.failure(
          ValidationError(field: 'image', reason: '画像サイズが大きすぎます（最大10MB）'),
        );
      }

      final metadataResult = await getImageMetadata(imageFile);
      if (metadataResult.isFailure) {
        return ResultState.failure(metadataResult.errorOrNull!);
      }

      return const Success(true);
    } catch (e) {
      return ResultState.failure(UnknownError.toString()));
    }
  }
}

final petImageUploadServiceProvider = Provider<PetImageUploadService>((ref) {
  final petApiService = ref.read(petApiServiceProvider);
  return PetImageUploadService(petApiService);
});

final petApiServiceProvider = Provider<PetApiService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PetApiService(apiClient);
});
