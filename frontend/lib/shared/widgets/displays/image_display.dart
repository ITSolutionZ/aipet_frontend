import 'dart:io';

import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 범용 이미지 표시 위젯 - 메모리 최적화 버전
class ImageDisplay extends StatefulWidget {
  final String? imagePath;
  final dynamic imageFile; // String 또는 File을 받을 수 있도록 변경
  final double width;
  final double height;
  final bool showUploadIcon;
  final VoidCallback? onTap;
  final Widget? badge;
  final BoxFit fit;
  final String? placeholderAsset;
  final Widget? placeholder;

  const ImageDisplay({
    super.key,
    this.imagePath,
    this.imageFile,
    this.width = 180,
    this.height = 180,
    this.showUploadIcon = false,
    this.onTap,
    this.badge,
    this.fit = BoxFit.cover,
    this.placeholderAsset,
    this.placeholder,
  });

  @override
  ImageDisplayState createState() => ImageDisplayState();
}

class ImageDisplayState extends State<ImageDisplay>
    with AutomaticKeepAliveClientMixin {
  late ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  @override
  void didUpdateWidget(ImageDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.imageFile != widget.imageFile) {
      _disposeImage();
      _initializeImage();
    }
  }

  @override
  void dispose() {
    _disposeImage();
    super.dispose();
  }

  void _initializeImage() {
    _imageProvider = _getImageProvider();
    if (_imageProvider != null) {
      _imageStream = _imageProvider!.resolve(ImageConfiguration.empty);
      _listener = ImageStreamListener(_onImageLoaded, onError: _onImageError);
      _imageStream?.addListener(_listener!);
    }
  }

  void _disposeImage() {
    if (_listener != null && _imageStream != null) {
      _imageStream!.removeListener(_listener!);
    }
    _imageStream = null;
    _listener = null;
    _imageProvider = null;
  }

  void _onImageLoaded(ImageInfo info, bool synchronousCall) {
    if (mounted) {
      setState(() {}); // 이미지 로드 완료 시 상태 업데이트
    }
  }

  void _onImageError(Object error, StackTrace? stackTrace) {
    // 에러 처리 - 필요시 로깅
    debugPrint('Image loading error: $error');
  }

  ImageProvider? _getImageProvider() {
    // File 객체가 있는 경우
    if (widget.imageFile != null && widget.imageFile is File) {
      return FileImage(widget.imageFile as File);
    }

    // 이미지 경로가 있는 경우 - 강화된 로컬 저장 지원
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      debugPrint('🖼️ ImageDisplay - imagePath: ${widget.imagePath}');

      // 상대 경로를 절대 경로로 변환
      final storageService = ImageStorageService();
      final absolutePath =
          storageService.getAbsolutePath(widget.imagePath!) ??
          widget.imagePath!;
      debugPrint('🖼️ ImageDisplay - absolutePath: $absolutePath');

      final imageType = ImageService.getImageType(absolutePath);
      debugPrint('🖼️ ImageDisplay - imageType: $imageType');

      switch (imageType) {
        case ImageType.file:
          final file = File(absolutePath);
          final fileExists = file.existsSync();
          debugPrint('🖼️ ImageDisplay - File exists: $fileExists');

          if (!fileExists) {
            debugPrint('❌ ImageDisplay - File does not exist: $absolutePath');
            return null;
          }
          return FileImage(file);
        case ImageType.network:
          return NetworkImage(absolutePath);
        case ImageType.asset:
          return AssetImage(absolutePath);
      }
    }

    // String 형태의 imageFile (경로) - 강화된 로컬 저장 지원
    if (widget.imageFile != null && widget.imageFile is String) {
      final String path = widget.imageFile as String;
      debugPrint('🖼️ ImageDisplay - imageFile path: $path');

      // 상대 경로를 절대 경로로 변환
      final storageService = ImageStorageService();
      final absolutePath = storageService.getAbsolutePath(path) ?? path;
      debugPrint('🖼️ ImageDisplay - absolutePath: $absolutePath');

      final imageType = ImageService.getImageType(absolutePath);
      debugPrint('🖼️ ImageDisplay - imageType: $imageType');

      switch (imageType) {
        case ImageType.file:
          final file = File(absolutePath);
          final fileExists = file.existsSync();
          debugPrint('🖼️ ImageDisplay - File exists: $fileExists');

          if (!fileExists) {
            debugPrint('❌ ImageDisplay - File does not exist: $absolutePath');
            return null;
          }
          return FileImage(file);
        case ImageType.network:
          return NetworkImage(absolutePath);
        case ImageType.asset:
          return AssetImage(absolutePath);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: _buildImageContent(),
            ),
          ),

          // 업로드 아이콘
          if (widget.showUploadIcon)
            Positioned(
              bottom: -8,
              right: -8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.pointBrown,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pureWhite, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.pureWhite,
                  size: 18,
                ),
              ),
            ),

          // 배지
          if (widget.badge != null)
            Positioned(top: 8, right: 8, child: widget.badge!),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (_imageProvider == null) {
      return _buildPlaceholder();
    }

    return Image(
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.pointBrown,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    if (widget.placeholderAsset != null) {
      return Image.asset(
        widget.placeholderAsset!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: (widget.width * 2).round(),
        cacheHeight: (widget.height * 2).round(),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: widget.width * 0.3,
            color: AppColors.pointGray.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
