import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/image_management_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_management_providers.g.dart';

/// 이미지 관리 서비스 Provider
@riverpod
ImageManagementService imageManagementService(Ref ref) {
  return ImageManagementService();
}

/// 저장된 이미지 목록 상태 관리
@riverpod
class SavedImagesNotifier extends _$SavedImagesNotifier {
  @override
  Future<List<String>> build() async {
    final service = ref.read(imageManagementServiceProvider);
    final result = await service.getAllSavedImages();

    if (result.isSuccess) {
      return result.dataOrNull ?? [];
    } else {
      throw Exception(result.errorOrNull);
    }
  }

  /// 새 이미지 추가
  Future<void> addImage(String imagePath) async {
    final currentState = await future;
    state = AsyncData([imagePath, ...currentState]);
  }

  /// 이미지 삭제
  Future<void> removeImage(String imagePath) async {
    final service = ref.read(imageManagementServiceProvider);
    final deleteResult = await service.deleteImage(imagePath);

    if (deleteResult.isSuccess) {
      final currentState = await future;
      state = AsyncData(
        currentState.where((path) => path != imagePath).toList(),
      );
    } else {
      throw Exception(deleteResult.errorOrNull);
    }
  }

  /// 이미지 목록 새로고침
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// 이미지 캐시 정리
  Future<int> cleanCache({int maxAgeInDays = 30}) async {
    final service = ref.read(imageManagementServiceProvider);
    final result = await service.cleanImageCache(maxAgeInDays: maxAgeInDays);

    if (result.isSuccess) {
      await refresh(); // 목록 갱신
      return result.dataOrNull ?? 0;
    } else {
      throw Exception(result.errorOrNull);
    }
  }
}

/// 이미지 선택 상태 관리
@riverpod
class ImageSelectionNotifier extends _$ImageSelectionNotifier {
  @override
  List<String> build() => [];

  /// 이미지 선택/선택 해제
  void toggleSelection(String imagePath) {
    final currentSelection = state;
    if (currentSelection.contains(imagePath)) {
      state = currentSelection.where((path) => path != imagePath).toList();
    } else {
      state = [...currentSelection, imagePath];
    }
  }

  /// 모든 선택 해제
  void clearSelection() {
    state = [];
  }

  /// 모든 이미지 선택
  void selectAll(List<String> allImagePaths) {
    state = [...allImagePaths];
  }

  /// 선택된 이미지 개수
  int get selectedCount => state.length;

  /// 특정 이미지가 선택되었는지 확인
  bool isSelected(String imagePath) => state.contains(imagePath);
}

/// 이미지 업로드 상태 관리
@riverpod
class ImageUploadNotifier extends _$ImageUploadNotifier {
  @override
  ImageUploadState build() => const ImageUploadState();

  /// 업로드 시작
  void startUpload(String imagePath) {
    state = state.copyWith(
      isUploading: true,
      currentUploadPath: imagePath,
      progress: 0.0,
      error: null,
    );
  }

  /// 업로드 진행률 업데이트
  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  /// 업로드 완료
  void completeUpload() {
    state = state.copyWith(
      isUploading: false,
      currentUploadPath: null,
      progress: 1.0,
    );
  }

  /// 업로드 에러
  void setError(String error) {
    state = state.copyWith(
      isUploading: false,
      error: error,
      currentUploadPath: null,
    );
  }

  /// 상태 초기화
  void reset() {
    state = const ImageUploadState();
  }
}

/// 이미지 업로드 상태 클래스
class ImageUploadState {
  final bool isUploading;
  final String? currentUploadPath;
  final double progress;
  final String? error;

  const ImageUploadState({
    this.isUploading = false,
    this.currentUploadPath,
    this.progress = 0.0,
    this.error,
  });

  ImageUploadState copyWith({
    bool? isUploading,
    String? currentUploadPath,
    double? progress,
    String? error,
  }) {
    return ImageUploadState(
      isUploading: isUploading ?? this.isUploading,
      currentUploadPath: currentUploadPath ?? this.currentUploadPath,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

/// 이미지 압축 상태 관리
@riverpod
class ImageCompressionNotifier extends _$ImageCompressionNotifier {
  @override
  ImageCompressionState build() => const ImageCompressionState();

  /// 압축 시작
  Future<Result<String>> compressImage(
    String imagePath, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    state = state.copyWith(
      isCompressing: true,
      currentImagePath: imagePath,
      error: null,
    );

    try {
      final service = ref.read(imageManagementServiceProvider);
      final result = await service.compressImage(
        imagePath,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (result.isSuccess) {
        state = state.copyWith(isCompressing: false, currentImagePath: null);
        return result;
      } else {
        state = state.copyWith(
          isCompressing: false,
          error: result.errorOrNull,
          currentImagePath: null,
        );
        return result;
      }
    } catch (error) {
      state = state.copyWith(
        isCompressing: false,
        error: error.toString(),
        currentImagePath: null,
      );
      return Result.failure('이미지 압축 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// 상태 초기화
  void reset() {
    state = const ImageCompressionState();
  }
}

/// 이미지 압축 상태 클래스
class ImageCompressionState {
  final bool isCompressing;
  final String? currentImagePath;
  final String? error;

  const ImageCompressionState({
    this.isCompressing = false,
    this.currentImagePath,
    this.error,
  });

  ImageCompressionState copyWith({
    bool? isCompressing,
    String? currentImagePath,
    String? error,
  }) {
    return ImageCompressionState(
      isCompressing: isCompressing ?? this.isCompressing,
      currentImagePath: currentImagePath ?? this.currentImagePath,
      error: error ?? this.error,
    );
  }
}

/// 저장소 통계 Provider
@riverpod
Future<StorageStats> storageStats(Ref ref) async {
  final service = ref.read(imageManagementServiceProvider);

  final imagesResult = await service.getAllSavedImages();
  final totalSizeResult = await service.getTotalStorageSize();

  final imageCount = imagesResult.isSuccess
      ? (imagesResult.dataOrNull?.length ?? 0)
      : 0;
  final totalSize = totalSizeResult.isSuccess
      ? (totalSizeResult.dataOrNull ?? 0)
      : 0;

  return StorageStats(imageCount: imageCount, totalSizeInBytes: totalSize);
}

/// 저장소 통계 클래스
class StorageStats {
  final int imageCount;
  final int totalSizeInBytes;

  const StorageStats({
    required this.imageCount,
    required this.totalSizeInBytes,
  });

  /// 크기를 사람이 읽기 쉬운 형태로 변환
  String get formattedSize {
    if (totalSizeInBytes < 1024) {
      return '${totalSizeInBytes}B';
    } else if (totalSizeInBytes < 1024 * 1024) {
      return '${(totalSizeInBytes / 1024).toStringAsFixed(1)}KB';
    } else if (totalSizeInBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(totalSizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
}
