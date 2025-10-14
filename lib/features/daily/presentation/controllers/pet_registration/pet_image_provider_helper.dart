import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 펫 이미지 Provider 헬퍼
///
/// 이미지 경로에 따른 적절한 ImageProvider를 반환하는 유틸리티
class PetImageProviderHelper {
  PetImageProviderHelper._();

  /// 이미지 경로로부터 ImageProvider 생성
  static ImageProvider<Object>? getImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    // HTTP/HTTPS URL
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    // Asset 경로
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    // Web 환경
    if (kIsWeb) {
      return NetworkImage(path);
    }

    // 로컬 파일 경로
    try {
      return FileImage(File(path));
    } catch (_) {
      return null;
    }
  }
}
