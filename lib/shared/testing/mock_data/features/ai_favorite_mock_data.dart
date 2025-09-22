import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../features/ai/domain/entities/ai_favorite_qa_entity.dart';
import '../../../../../features/pet_registor/domain/entities/pet_profile_entity.dart';

part 'ai_favorite_mock_data.g.dart';

/// AI 즐겨찾기 QA Mock 데이터 프로바이더
///
/// 실제 API 연계 전까지 사용하는 즐겨찾기 Mock 데이터를 중앙 관리합니다.
@riverpod
List<AiFavoriteQaEntity> aiFavoriteMockData(Ref ref) {
  final now = DateTime.now();
  final mockPet1 = PetProfileEntity(
    id: 'pet1',
    name: 'ゆうくん',
    type: 'dog',
    breed: '柴犬',
    birthDate: DateTime(2020, 3, 15),
    gender: 'male',
    weight: 12.5,
    ownerId: 'user1',
    createdAt: now.subtract(const Duration(days: 30)),
    updatedAt: now.subtract(const Duration(days: 1)),
    imagePath: null,
  );

  final mockPet2 = PetProfileEntity(
    id: 'pet2',
    name: 'みゃあちゃん',
    type: 'cat',
    breed: 'マンチカン',
    birthDate: DateTime(2021, 7, 20),
    gender: 'female',
    weight: 3.8,
    ownerId: 'user1',
    createdAt: now.subtract(const Duration(days: 20)),
    updatedAt: now.subtract(const Duration(days: 1)),
    imagePath: null,
  );

  return [
    AiFavoriteQaEntity(
      id: 'fav1',
      question: 'ペットが食事を拒否する時はどうしたらいいですか？',
      answer:
          '🍽️ お腹の調子が悪い理由はたくさんあります:\n\n1. **健康上の問題**: 歯の問題, 消化器の問題\n2. **ストレス**: 環境の変化, 新しい食事\n3. **活動量不足**: 運動が不足すると食欲が落ちます\n\n**解決策:**\n• 定められた時間に定期的に食事\n• 食器を清潔に保つ\n• 十分な運動でエネルギーを消費\n• 継続的に症状があれば獣医師に相談を推奨',
      pet: mockPet1,
      categoryId: 'health',
      categoryName: '健康',
      createdAt: now.subtract(const Duration(days: 2)),
      originalTimestamp: now.subtract(const Duration(days: 2, hours: 1)),
    ),
    AiFavoriteQaEntity(
      id: 'fav2',
      question: '散歩の時間はどれくらいかかりますか?',
      answer:
          '🚶‍♂️ ペットの散歩ガイド:\n\n**小型犬 (5kg 未満)**\n• 1日30-60分 (2-3回に分けて)\n\n**中型犬 (5-25kg)**\n• 1日60-90分 (朝, 夕方)\n\n**大型犬 (25kg 以上)**\n• 1日90-120分 (活発な運動が必要)\n\n**注意事項:**\n• 暑い時間帯を避ける (アスファルトの熱傷に注意)\n• 十分な水分補給\n• 段階的に運動量を増やす',
      pet: mockPet1,
      categoryId: 'exercise',
      categoryName: '運動',
      createdAt: now.subtract(const Duration(days: 1)),
      originalTimestamp: now.subtract(const Duration(days: 1, hours: 2)),
    ),
    AiFavoriteQaEntity(
      id: 'fav3',
      question: '猫の適正なフード量はどれくらいですか？',
      answer:
          '🐱 猫のフード量ガイド:\n\n**年齢別の基準:**\n• 子猫 (2-12か月): 体重×80-100kcal/日\n• 成猫 (1-7歳): 体重×70-80kcal/日\n• 高齢猫 (7歳以上): 体重×60-70kcal/日\n\n**フードタイプ別:**\n• ドライフード: 1日2-3回に分けて\n• ウェットフード: 1日2回が理想\n\n**注意事項:**\n• 急な変更は避ける\n• 水分摂取量も重要\n• 体重変化を定期的にチェック',
      pet: mockPet2,
      categoryId: 'feeding',
      categoryName: '食事',
      createdAt: now.subtract(const Duration(hours: 5)),
      originalTimestamp: now.subtract(const Duration(hours: 6)),
    ),
    AiFavoriteQaEntity(
      id: 'fav4',
      question: '一般的なペットケアについて教えてください',
      answer:
          '🐾 一般的なペットケアの基本:\n\n**日常ケア:**\n• 定期的なブラッシング\n• 歯磨きまたは歯のケア\n• 爪切り\n• 耳掃除\n\n**健康管理:**\n• 年1-2回の健康チェック\n• 予防接種の継続\n• 体重管理\n• 異常な行動や症状の観察\n\n**環境整備:**\n• 清潔な生活空間\n• 適切な温度管理\n• 十分な運動と遊び時間',
      pet: null,
      categoryId: 'general',
      categoryName: '一般',
      createdAt: now.subtract(const Duration(hours: 3)),
      originalTimestamp: now.subtract(const Duration(hours: 4)),
    ),
    AiFavoriteQaEntity(
      id: 'fav5',
      question: '猫が夜中に鳴くのはなぜですか？',
      answer:
          '🐱 猫が夜中に鳴く理由:\n\n**主な原因:**\n• 狩猟本能の発露 (野生の名残)\n• 注意を引きたい\n• ストレスや不安\n• 病気や体調不良\n• 発情期の行動\n\n**対処法:**\n• 昼間に十分遊ばせる\n• 夜間の環境を整える\n• 定期的な健康チェック\n• ストレス要因の除去\n• 必要に応じて避妊・去勢手術を検討',
      pet: mockPet2,
      categoryId: 'behavior',
      categoryName: '行動',
      createdAt: now.subtract(const Duration(hours: 8)),
      originalTimestamp: now.subtract(const Duration(hours: 9)),
    ),
    AiFavoriteQaEntity(
      id: 'fav6',
      question: '犬の毛玉ケアはどうしたらいいですか？',
      answer:
          '✂️ 犬の毛玉ケアガイド:\n\n**予防方法:**\n• 毎日のブラッシング (長毛種は特に重要)\n• 適切なブラシの選択\n• シャンプー後の完全な乾燥\n\n**毛玉ができてしまった場合:**\n• 小さな毛玉: 手でほぐしながらブラッシング\n• 大きな毛玉: 毛玉カッターで慎重に除去\n• ひどい場合: プロのトリマーに相談\n\n**注意事項:**\n• 無理に引っ張らない\n• 皮膚を傷つけないよう注意\n• 定期的なトリミングサロンの利用',
      pet: mockPet1,
      categoryId: 'grooming',
      categoryName: 'グルーミング',
      createdAt: now.subtract(const Duration(hours: 12)),
      originalTimestamp: now.subtract(const Duration(hours: 13)),
    ),
  ];
}

/// 즐겨찾기 카테고리별 목록 프로바이더
@riverpod
List<AiFavoriteQaEntity> aiFavoritesByCategory(Ref ref, String categoryId) {
  final favorites = ref.watch(aiFavoriteMockDataProvider);
  return favorites
      .where((favorite) => favorite.categoryId == categoryId)
      .toList();
}

/// 즐겨찾기 펫별 목록 프로바이더
@riverpod
List<AiFavoriteQaEntity> aiFavoritesByPet(Ref ref, String petId) {
  final favorites = ref.watch(aiFavoriteMockDataProvider);
  return favorites.where((favorite) => favorite.pet?.id == petId).toList();
}

/// 일반 상담 즐겨찾기 목록 프로바이더 (펫이 지정되지 않은 경우)
@riverpod
List<AiFavoriteQaEntity> aiGeneralFavorites(Ref ref) {
  final favorites = ref.watch(aiFavoriteMockDataProvider);
  return favorites.where((favorite) => favorite.pet == null).toList();
}
