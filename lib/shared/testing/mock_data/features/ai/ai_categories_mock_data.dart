import 'package:aipet_frontend/features/ai/ai.dart';
import 'package:flutter/material.dart';

/// AI 카테고리 관련 Mock 데이터 서비스
///
/// AI 카테고리 데이터를 중앙에서 관리하며, 향후 데이터베이스나 설정 파일에서 로드할 수 있도록 설계
class AiCategoriesMockData {
  /// 기본 카테고리 목록
  static List<AiCategoryEntity> getDefaultCategories() {
    return [
      const AiCategoryEntity(
        id: 'health',
        name: '健康',
        description: '病気、怪我、健康管理について',
        icon: Icons.medical_services,
        color: Colors.red,
      ),
      const AiCategoryEntity(
        id: 'food',
        name: '食事',
        description: 'フード、栄養、給餌について',
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      const AiCategoryEntity(
        id: 'toilet',
        name: '排便',
        description: 'トイレトレーニング、排便問題',
        icon: Icons.pets,
        color: Colors.brown,
      ),
      const AiCategoryEntity(
        id: 'recipe',
        name: '手作りレシピ',
        description: 'ペット用手作り料理レシピ',
        icon: Icons.kitchen,
        color: Colors.green,
      ),
      const AiCategoryEntity(
        id: 'behavior',
        name: '行動',
        description: 'しつけ、問題行動、トレーニング',
        icon: Icons.psychology,
        color: Colors.blue,
      ),
      const AiCategoryEntity(
        id: 'grooming',
        name: 'グルーミング',
        description: '毛づくり、お風呂、ケア',
        icon: Icons.content_cut,
        color: Colors.purple,
      ),
      const AiCategoryEntity(
        id: 'general',
        name: '一般相談',
        description: '上記以外の一般的な相談',
        icon: Icons.help_outline,
        color: Colors.grey,
      ),
      const AiCategoryEntity(
        id: 'others',
        name: 'その他',
        description: 'その他のご相談やご質問',
        icon: Icons.more_horiz,
        color: Colors.blueGrey,
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

  /// 특정 색상의 카테고리들 조회
  static List<AiCategoryEntity> getCategoriesByColor(Color color) {
    return getDefaultCategories()
        .where((category) => category.color == color)
        .toList();
  }

  /// 카테고리 ID 목록 조회
  static List<String> getAllCategoryIds() {
    return getDefaultCategories().map((category) => category.id).toList();
  }

  /// 카테고리 이름 목록 조회
  static List<String> getAllCategoryNames() {
    return getDefaultCategories().map((category) => category.name).toList();
  }
}
