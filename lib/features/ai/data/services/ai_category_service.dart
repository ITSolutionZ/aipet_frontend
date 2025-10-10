import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:flutter/material.dart';

/// AI 카테고리 데이터 관리 서비스
///
/// 카테고리 데이터를 중앙에서 관리하며, 향후 데이터베이스나 설정 파일에서 로드할 수 있도록 설계
class AiCategoryService {
  /// 기본 카테고리 목록
  static List<AiCategoryEntity> getDefaultCategories() {
    return [
      const AiCategoryEntity(
        id: 'health',
        name: '健康',
        description: '病気、怪我、健康管理',
        icon: Icons.medical_services,
        color: Colors.red,
      ),
      const AiCategoryEntity(
        id: 'food',
        name: '食事',
        description: 'フード、栄養、給餌',
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      const AiCategoryEntity(
        id: 'behavior',
        name: '行動',
        description: 'しつけ、問題行動',
        icon: Icons.psychology,
        color: Colors.purple,
      ),
      const AiCategoryEntity(
        id: 'grooming',
        name: 'グルーミング',
        description: 'お手入れ、毛づくろい',
        icon: Icons.content_cut,
        color: Colors.pink,
      ),
      const AiCategoryEntity(
        id: 'exercise',
        name: '運動',
        description: '散歩、遊び',
        icon: Icons.directions_walk,
        color: Colors.green,
      ),
      const AiCategoryEntity(
        id: 'general',
        name: 'その他',
        description: '一般的な相談',
        icon: Icons.help_outline,
        color: Colors.blue,
      ),
    ];
  }

  /// ID로 카테고리 찾기
  static AiCategoryEntity? findById(String id) {
    try {
      return getDefaultCategories().firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 카테고리 이름으로 찾기
  static AiCategoryEntity? findByName(String name) {
    try {
      return getDefaultCategories().firstWhere(
        (category) => category.name == name,
      );
    } catch (e) {
      return null;
    }
  }
}
