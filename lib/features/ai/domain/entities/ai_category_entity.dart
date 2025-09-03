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
  /// @deprecated 정적 데이터는 AiCategoryService.getDefaultCategories()를 사용하세요.
  static List<AiCategoryEntity> get defaultCategories {
    // 하위 호환성을 위해 유지하지만, 새로운 코드에서는 AiCategoryService 사용을 권장
    throw UnimplementedError(
      '정적 데이터는 더 이상 지원되지 않습니다. '
      'AiCategoryService.getDefaultCategories()를 사용하세요.',
    );
  }
}
