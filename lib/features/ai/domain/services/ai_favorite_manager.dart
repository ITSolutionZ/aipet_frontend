import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter/foundation.dart';

/// ⭐ AI 즐겨찾기 관리 서비스
///
/// AI 채팅의 즐겨찾기 메시지 관리 책임을 담당합니다.
/// - 즐겨찾기 추가/제거
/// - 즐겨찾기 목록 관리
/// - 즐겨찾기 검색 및 필터링
class AiFavoriteManager {
  static const String _tag = 'AiFavoriteManager';

  /// 즐겨찾기에 메시지 추가
  ///
  /// [currentFavoriteIds] 현재 즐겨찾기 ID 목록
  /// [currentFavoriteQAs] 현재 즐겨찾기 QA 목록
  /// [message] 즐겨찾기에 추가할 메시지
  /// [userQuestion] 해당 메시지의 질문 (컨텍스트용)
  /// [selectedCategory] 현재 선택된 카테고리
  /// [selectedPet] 현재 선택된 펫
  /// [return] 업데이트된 즐겨찾기 상태
  static Result<FavoriteUpdateResult> addToFavorites({
    required List<String> currentFavoriteIds,
    required List<AiFavoriteQaEntity> currentFavoriteQAs,
    required AiMessageEntity message,
    required String userQuestion,
    AiCategoryEntity? selectedCategory,
    PetProfileEntity? selectedPet,
  }) {
    try {
      // 이미 즐겨찾기에 있는지 확인
      if (currentFavoriteIds.contains(message.id)) {
        return ResultFactory.failure('이미 즐겨찾기에 추가된 메시지입니다');
      }

      // 유효성 검증
      final validationResult = _validateForFavorite(message, userQuestion);
      if (!validationResult.isSuccess) {
        return ResultFactory.failure(
          validationResult.errorOrNull ?? 'Validation failed',
        );
      }

      // 새로운 즐겨찾기 항목 생성
      final favoriteQA = AiFavoriteQaEntity(
        id: message.id,
        question: userQuestion.trim(),
        answer: message.content.trim(),
        pet: selectedPet,
        categoryId: selectedCategory?.id,
        categoryName: selectedCategory?.name,
        createdAt: DateTime.now(),
        originalTimestamp: message.timestamp,
      );

      // 업데이트된 목록 생성
      final updatedIds = List<String>.from(currentFavoriteIds)..add(message.id);
      final updatedQAs = List<AiFavoriteQaEntity>.from(currentFavoriteQAs)
        ..add(favoriteQA);

      // 즐겨찾기 개수 제한 (100개)
      const maxFavorites = 100;
      if (updatedQAs.length > maxFavorites) {
        // 가장 오래된 것부터 제거
        final removeCount = updatedQAs.length - maxFavorites;
        final removedItems = updatedQAs.take(removeCount).toList();

        updatedQAs.removeRange(0, removeCount);
        for (final item in removedItems) {
          updatedIds.remove(item.id);
        }

        if (kDebugMode) {
          debugPrint(
            '[$_tag] Removed $removeCount old favorites (limit: $maxFavorites)',
          );
        }
      }

      final result = FavoriteUpdateResult(
        favoriteIds: updatedIds,
        favoriteQAs: updatedQAs,
        operation: FavoriteOperation.add,
        affectedMessage: message,
        message: '즐겨찾기에 추가되었습니다',
      );

      if (kDebugMode) {
        debugPrint(
          '[$_tag] ⭐ Added to favorites: ${message.id} (total: ${updatedIds.length})',
        );
      }

      return ResultFactory.success(result, result.message);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error adding to favorites: $error\n$stackTrace');
      }
      return ResultFactory.failure('즐겨찾기 추가 중 오류 발생: $error');
    }
  }

  /// 즐겨찾기에서 제거
  ///
  /// [currentFavoriteIds] 현재 즐겨찾기 ID 목록
  /// [currentFavoriteQAs] 현재 즐겨찾기 QA 목록
  /// [messageId] 제거할 메시지 ID
  /// [return] 업데이트된 즐겨찾기 상태
  static Result<FavoriteUpdateResult> removeFromFavorites({
    required List<String> currentFavoriteIds,
    required List<AiFavoriteQaEntity> currentFavoriteQAs,
    required String messageId,
  }) {
    try {
      // 즐겨찾기에 있는지 확인
      if (!currentFavoriteIds.contains(messageId)) {
        return ResultFactory.failure('즐겨찾기에 없는 메시지입니다');
      }

      // 제거할 QA 항목 찾기
      final qaToRemove = currentFavoriteQAs.firstWhere(
        (qa) => qa.id == messageId,
        orElse: () => throw StateError('QA not found'),
      );

      // 업데이트된 목록 생성
      final updatedIds = List<String>.from(currentFavoriteIds)
        ..remove(messageId);
      final updatedQAs = List<AiFavoriteQaEntity>.from(currentFavoriteQAs)
        ..removeWhere((qa) => qa.id == messageId);

      final result = FavoriteUpdateResult(
        favoriteIds: updatedIds,
        favoriteQAs: updatedQAs,
        operation: FavoriteOperation.remove,
        affectedMessage: null,
        message: '즐겨찾기에서 제거되었습니다',
        removedQA: qaToRemove,
      );

      if (kDebugMode) {
        debugPrint(
          '[$_tag] 💔 Removed from favorites: $messageId (remaining: ${updatedIds.length})',
        );
      }

      return ResultFactory.success(result, result.message);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[$_tag] Error removing from favorites: $error\n$stackTrace',
        );
      }
      return ResultFactory.failure('즐겨찾기 제거 중 오류 발생: $error');
    }
  }

  /// 모든 즐겨찾기 삭제
  ///
  /// [return] 빈 즐겨찾기 상태
  static Result<FavoriteUpdateResult> clearAllFavorites() {
    try {
      const result = FavoriteUpdateResult(
        favoriteIds: <String>[],
        favoriteQAs: <AiFavoriteQaEntity>[],
        operation: FavoriteOperation.clearAll,
        affectedMessage: null,
        message: '모든 즐겨찾기가 삭제되었습니다',
      );

      if (kDebugMode) {
        debugPrint('[$_tag] 🗑️ All favorites cleared');
      }

      return ResultFactory.success(result, result.message);
    } catch (error) {
      return ResultFactory.failure('즐겨찾기 전체 삭제 중 오류 발생: $error');
    }
  }

  /// 즐겨찾기 검색 및 필터링
  ///
  /// [favoriteQAs] 검색할 즐겨찾기 목록
  /// [query] 검색 키워드
  /// [categoryId] 카테고리 필터
  /// [petId] 펫 필터
  /// [return] 필터링된 즐겨찾기 목록
  static Result<List<AiFavoriteQaEntity>> searchFavorites({
    required List<AiFavoriteQaEntity> favoriteQAs,
    String? query,
    String? categoryId,
    String? petId,
  }) {
    try {
      var filteredList = List<AiFavoriteQaEntity>.from(favoriteQAs);

      // 텍스트 검색
      if (query != null && query.trim().isNotEmpty) {
        final searchQuery = query.trim().toLowerCase();
        filteredList = filteredList.where((qa) {
          return qa.question.toLowerCase().contains(searchQuery) ||
              qa.answer.toLowerCase().contains(searchQuery);
        }).toList();
      }

      // 카테고리 필터
      if (categoryId != null && categoryId.isNotEmpty) {
        filteredList = filteredList
            .where((qa) => qa.categoryId == categoryId)
            .toList();
      }

      // 펫 필터
      if (petId != null && petId.isNotEmpty) {
        filteredList = filteredList.where((qa) => qa.pet?.id == petId).toList();
      }

      // 최신순 정렬
      filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (kDebugMode) {
        debugPrint(
          '[$_tag] 🔍 Favorites filtered: ${favoriteQAs.length} → ${filteredList.length}',
        );
      }

      return ResultFactory.success(
        filteredList,
        'Favorites filtered successfully',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error searching favorites: $error\n$stackTrace');
      }
      return ResultFactory.failure('즐겨찾기 검색 중 오류 발생: $error');
    }
  }

  /// 즐겨찾기 통계 생성
  ///
  /// [favoriteQAs] 통계를 생성할 즐겨찾기 목록
  /// [return] 즐겨찾기 통계
  static FavoriteStatistics generateStatistics(
    List<AiFavoriteQaEntity> favoriteQAs,
  ) {
    try {
      if (favoriteQAs.isEmpty) {
        return FavoriteStatistics.empty();
      }

      // 카테고리별 분포
      final categoryDistribution = <String, int>{};
      final petDistribution = <String, int>{};
      int totalCharacters = 0;

      for (final qa in favoriteQAs) {
        // 카테고리 분포
        final category = qa.categoryName ?? 'Unknown';
        categoryDistribution[category] =
            (categoryDistribution[category] ?? 0) + 1;

        // 펫 분포
        final petName = qa.pet?.name ?? 'No Pet';
        petDistribution[petName] = (petDistribution[petName] ?? 0) + 1;

        // 문자 수
        totalCharacters += qa.question.length + qa.answer.length;
      }

      // 최근 추가된 날짜
      final sortedByDate = List<AiFavoriteQaEntity>.from(favoriteQAs)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return FavoriteStatistics(
        totalFavorites: favoriteQAs.length,
        categoryDistribution: categoryDistribution,
        petDistribution: petDistribution,
        totalCharacters: totalCharacters,
        averageCharactersPerFavorite: totalCharacters / favoriteQAs.length,
        mostRecentlyAdded: sortedByDate.first.createdAt,
        oldestAdded: sortedByDate.last.createdAt,
        topCategory: _getTopEntry(categoryDistribution),
        topPet: _getTopEntry(petDistribution),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error generating statistics: $error');
      }
      return FavoriteStatistics.empty();
    }
  }

  /// 즐겨찾기 상태 검증
  ///
  /// [favoriteIds] 즐겨찾기 ID 목록
  /// [favoriteQAs] 즐겨찾기 QA 목록
  /// [return] 검증 결과
  static Result<FavoriteValidationResult> validateFavoriteState({
    required List<String> favoriteIds,
    required List<AiFavoriteQaEntity> favoriteQAs,
  }) {
    try {
      final issues = <String>[];
      const int fixedCount = 0;

      // 1. 길이 일치 확인
      if (favoriteIds.length != favoriteQAs.length) {
        issues.add(
          'ID 목록과 QA 목록의 길이가 일치하지 않음 (${favoriteIds.length} vs ${favoriteQAs.length})',
        );
      }

      // 2. ID 일치 확인
      final qaIds = favoriteQAs.map((qa) => qa.id).toSet();
      final idSet = favoriteIds.toSet();

      final missingInQAs = idSet.difference(qaIds);
      final missingInIds = qaIds.difference(idSet);

      if (missingInQAs.isNotEmpty) {
        issues.add('QA 목록에 없는 ID들: ${missingInQAs.join(', ')}');
      }

      if (missingInIds.isNotEmpty) {
        issues.add('ID 목록에 없는 QA들: ${missingInIds.join(', ')}');
      }

      // 3. 중복 확인
      final duplicateIds = _findDuplicates(favoriteIds);
      if (duplicateIds.isNotEmpty) {
        issues.add('중복된 즐겨찾기 ID들: ${duplicateIds.join(', ')}');
      }

      final validationResult = FavoriteValidationResult(
        isValid: issues.isEmpty,
        issues: issues,
        fixedCount: fixedCount,
        recommendedAction: issues.isNotEmpty ? '즐겨찾기 목록 동기화 필요' : null,
      );

      if (issues.isNotEmpty && kDebugMode) {
        debugPrint('[$_tag] ⚠️ Favorite validation issues: ${issues.length}');
        for (final issue in issues) {
          debugPrint('[$_tag]   - $issue');
        }
      }

      return ResultFactory.success(
        validationResult,
        'Favorite validation completed',
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error validating favorites: $error\n$stackTrace');
      }
      return ResultFactory.failure('즐겨찾기 검증 중 오류 발생: $error');
    }
  }

  // 내부 헬퍼 메서드들
  static Result<bool> _validateForFavorite(
    AiMessageEntity message,
    String userQuestion,
  ) {
    if (message.type != MessageType.assistant) {
      return ResultFactory.failure('AI 응답 메시지만 즐겨찾기에 추가할 수 있습니다');
    }

    if (message.content.trim().length < 10) {
      return ResultFactory.failure('메시지가 너무 짧아 즐겨찾기에 적합하지 않습니다');
    }

    if (userQuestion.trim().length < 3) {
      return ResultFactory.failure('질문이 너무 짧습니다');
    }

    return ResultFactory.success(true, 'Valid for favorite');
  }

  static String? _getTopEntry(Map<String, int> distribution) {
    if (distribution.isEmpty) return null;

    var maxCount = 0;
    String? topEntry;

    for (final entry in distribution.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        topEntry = entry.key;
      }
    }

    return topEntry;
  }

  static List<String> _findDuplicates(List<String> list) {
    final seen = <String>{};
    final duplicates = <String>{};

    for (final item in list) {
      if (seen.contains(item)) {
        duplicates.add(item);
      } else {
        seen.add(item);
      }
    }

    return duplicates.toList();
  }
}

/// 즐겨찾기 업데이트 결과
class FavoriteUpdateResult {
  final List<String> favoriteIds;
  final List<AiFavoriteQaEntity> favoriteQAs;
  final FavoriteOperation operation;
  final AiMessageEntity? affectedMessage;
  final String message;
  final AiFavoriteQaEntity? removedQA;

  const FavoriteUpdateResult({
    required this.favoriteIds,
    required this.favoriteQAs,
    required this.operation,
    required this.affectedMessage,
    required this.message,
    this.removedQA,
  });
}

/// 즐겨찾기 작업 유형
enum FavoriteOperation {
  add('Add'),
  remove('Remove'),
  clearAll('Clear All');

  const FavoriteOperation(this.displayName);
  final String displayName;
}

/// 즐겨찾기 통계
class FavoriteStatistics {
  final int totalFavorites;
  final Map<String, int> categoryDistribution;
  final Map<String, int> petDistribution;
  final int totalCharacters;
  final double averageCharactersPerFavorite;
  final DateTime mostRecentlyAdded;
  final DateTime oldestAdded;
  final String? topCategory;
  final String? topPet;

  const FavoriteStatistics({
    required this.totalFavorites,
    required this.categoryDistribution,
    required this.petDistribution,
    required this.totalCharacters,
    required this.averageCharactersPerFavorite,
    required this.mostRecentlyAdded,
    required this.oldestAdded,
    required this.topCategory,
    required this.topPet,
  });

  factory FavoriteStatistics.empty() {
    final now = DateTime.now();
    return FavoriteStatistics(
      totalFavorites: 0,
      categoryDistribution: {},
      petDistribution: {},
      totalCharacters: 0,
      averageCharactersPerFavorite: 0.0,
      mostRecentlyAdded: now,
      oldestAdded: now,
      topCategory: null,
      topPet: null,
    );
  }

  @override
  String toString() {
    return 'FavoriteStatistics('
        'total: $totalFavorites, '
        'topCategory: $topCategory, '
        'topPet: $topPet, '
        'avgChars: ${averageCharactersPerFavorite.toStringAsFixed(0)}'
        ')';
  }
}

/// 즐겨찾기 검증 결과
class FavoriteValidationResult {
  final bool isValid;
  final List<String> issues;
  final int fixedCount;
  final String? recommendedAction;

  const FavoriteValidationResult({
    required this.isValid,
    required this.issues,
    required this.fixedCount,
    required this.recommendedAction,
  });

  @override
  String toString() {
    return 'FavoriteValidationResult('
        'valid: $isValid, '
        'issues: ${issues.length}, '
        'fixed: $fixedCount'
        ')';
  }
}
