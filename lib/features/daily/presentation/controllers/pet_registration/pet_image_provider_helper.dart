import 'dart:io';

import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 펫 이미지 Provider 헬퍼 - 강화된 로컬 저장 지원
///
/// 이미지 경로에 따른 적절한 ImageProvider를 반환하는 유틸리티
class PetImageProviderHelper {
  PetImageProviderHelper._();

  /// 이미지 경로로부터 ImageProvider 생성 - 강화된 로컬 저장 지원
  static ImageProvider<Object>? getImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    debugPrint('🖼️ PetImageProviderHelper - path: $path');
    
    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(path) ?? path;
    debugPrint('🖼️ PetImageProviderHelper - absolutePath: $absolutePath');
    
    final imageType = ImageService.getImageType(absolutePath);
    debugPrint('🖼️ PetImageProviderHelper - imageType: $imageType');
    
    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        debugPrint('🖼️ PetImageProviderHelper - File exists: $fileExists');
        
        if (!fileExists) {
          debugPrint('❌ PetImageProviderHelper - File does not exist: $absolutePath');
          return const AssetImage('assets/icons/logos/aipet_logo.png');
        }
        return FileImage(file);
      case ImageType.network:
        return NetworkImage(absolutePath);
      case ImageType.asset:
        return AssetImage(absolutePath);
    }
  }
}
