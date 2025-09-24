import 'package:flutter/material.dart';

/// AI 상담 카테고리 엔티티
class AiCategoryEntity {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const AiCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  /// 기본 카테고리 목록 (AiCategoryService를 통해 접근)
  ///
  /// @deprecated 이 메서드는 더 이상 지원되지 않습니다.
  /// 대신 `AiCategoryService.getDefaultCategories()`를 사용하세요.
  ///
  /// ## 사용 권장 방법
  /// ```dart
  /// // 올바른 사용법
  /// final categories = AiCategoryService.getDefaultCategories();
  ///
  /// // 잘못된 사용법 (deprecated)
  /// final categories = AiCategoryEntity.defaultCategories; // 에러 발생
  /// ```
  static List<AiCategoryEntity> get defaultCategories {
    throw UnimplementedError(
      'AiCategoryEntity.defaultCategories는 더 이상 지원되지 않습니다. '
      'AiCategoryService.getDefaultCategories()를 사용하세요.',
    );
  }
}
