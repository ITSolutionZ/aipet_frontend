import 'dart:math';

import 'package:aipet_frontend/app/services/local_storage_service.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/utils/id_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../services/ai_local_storage_service.dart';

/// 🎯 AI Repository 구현체
///
/// AI 관련 데이터 접근을 담당하는 Repository의 구현체입니다.
///
/// ## 주요 기능
/// - OpenAI API를 통한 AI 응답 생성
/// - 로컬 저장소를 통한 데이터 영속성 관리
/// - Mock 데이터 서비스를 통한 개발 환경 지원
///
/// ## 아키텍처
/// - Clean Architecture의 Repository 패턴 구현
/// - 의존성 주입을 통한 테스트 가능한 구조
/// - 에러 처리 및 로깅을 통한 안정성 확보
class AiRepositoryImpl implements AiRepository {
  final AiLocalStorageService _localStorageService;
  final LocalStorageService _localStorage;
  final Ref ref;

  AiRepositoryImpl({required this.ref})
    : _localStorageService = AiLocalStorageService(),
      _localStorage = LocalStorageService.instance;

  /// 채팅 히스토리 조회
  ///
  /// 사용자의 채팅 히스토리를 조회합니다.
  ///
  /// ## 우선순위
  /// 1. 로컬 저장소에서 저장된 히스토리 조회
  /// 2. 로컬에 데이터가 없으면 Mock 데이터 반환 (개발 환경)
  ///
  /// ## 반환값
  /// - `List<AiMessageEntity>`: 채팅 메시지 목록
  /// ===== 추천 질문 관련 =====

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // 로컬 저장소에서 추천 질문 가져오기
    final questions = await _localStorage.ai.loadAiCategories();
    if (questions != null && questions.isNotEmpty) {
      return questions
          .map(
            (q) => AiSuggestedQuestionEntity(
              id: q['id'] ?? '',
              question: q['question'] ?? '',
              category: q['category'] ?? '',
              icon: Icons.help_outline,
              description: q['description'] as String?,
            ),
          )
          .toList();
    }
    return [];
  }

  /// 펫 정보 기반 맞춤형 추천 질문 가져오기
  @override
  Future<List<AiSuggestedQuestionEntity>> getPersonalizedSuggestedQuestions({
    String? category,
    PetProfileEntity? pet,
  }) async {
    // 기본 추천 질문 가져오기
    final baseQuestions = [
      AiSuggestedQuestionEntity(
        id: '1',
        question: 'ペットの健康管理について教えてください',
        category: category ?? 'health',
        icon: Icons.medical_services,
        description: '健康管理の基本について',
      ),
      AiSuggestedQuestionEntity(
        id: '2',
        question: 'おすすめのペットフードは何ですか？',
        category: category ?? 'food',
        icon: Icons.restaurant,
        description: 'フード選びのアドバイス',
      ),
      AiSuggestedQuestionEntity(
        id: '3',
        question: 'しつけの基本を教えてください',
        category: category ?? 'behavior',
        icon: Icons.psychology,
        description: 'しつけの基礎知識',
      ),
    ];

    // 카테고리와 펫 정보에 따라 필터링
    if (category != null) {
      return baseQuestions.where((q) => q.category == category).toList();
    }

    return baseQuestions;
  }

  @override
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  }) async {
    // 즐겨찾기 메시지 생성
    final favorite = AiFavoriteEntity(
      id: IdGenerator.generate(prefix: 'favorite'),
      message: message,
      petId: petId,
      petName: petName,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userNote: userNote,
    );

    // 로컬 저장소에 즐겨찾기 저장
    await _localStorageService.saveFavoriteMessage(favorite);

    return favorite;
  }

  @override
  Future<void> removeFavoriteMessage(String favoriteId) async {
    // 로컬 저장소에서 즐겨찾기 메시지 삭제
    await _localStorageService.removeFavoriteMessage(favoriteId);
  }

  @override
  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  }) async {
    // 로컬 저장소에서 즐겨찾기 메시지 목록 가져오기
    final favorites = await _localStorageService.loadFavoriteMessages();

    // 필터링 적용
    if (petId != null || category != null) {
      return favorites.where((favorite) {
        if (petId != null && favorite.petId != petId) return false;
        if (category != null && favorite.category != category) return false;
        return true;
      }).toList();
    }

    return favorites;
  }

  @override
  Future<List<AiFavoriteQaEntity>> getFavoriteQAs() async {
    // 로컬 저장소에서 즐겨찾기 QA 목록 가져오기
    return _localStorageService.loadFavoriteQAs();
  }

  /// ===== 분석 관련 =====

  @override
  Future<Result<AiAnalysisEntity>> analyzeMessage({
    required String message,
    String? petId,
    Map<String, dynamic>? context,
  }) async {
    try {
      // 간단한 분석 로직 (실제로는 더 복잡한 AI 분석)
      final analysis = AiAnalysisEntity.fromMessage(
        message: message,
        analysis: '메시지 분석이 완료되었습니다. 내용: $message',
        topics: _extractTopics(message),
        confidenceScore: 0.8,
      );

      return Result.success('메시지 분석 완료', analysis);
    } catch (e) {
      return Result.failure('메시지 분석 실패: $e');
    }
  }

  /// 즐겨찾기 토글
  @override
  Future<Result<bool>> toggleFavoriteMessage(String messageId) async {
    try {
      // Mock 구현 - 실제로는 로컬 저장소나 서버에서 즐겨찾기 상태 토글
      final isFavorite = Random().nextBool();
      return Result.success('즐겨찾기 토글 완료', isFavorite);
    } catch (e) {
      return Result.failure('즐겨찾기 토글 실패: $e');
    }
  }

  /// 파라미터와 함께 제안 질문 가져오기
  @override
  Future<Result<List<AiSuggestedQuestionEntity>>>
  getSuggestedQuestionsWithParams({String? petId, String? categoryId}) async {
    try {
      // Mock 제안 질문들
      final suggestions = [
        AiSuggestedQuestionEntity(
          id: '1',
          question: '우리 강아지 건강은 어떤가요?',
          category: categoryId ?? '건강',
          // relevanceScore: 0.9,
          icon: Icons.medical_services,
        ),
        AiSuggestedQuestionEntity(
          id: '2',
          question: '오늘 산책은 어떻게 해야 할까요?',
          category: categoryId ?? '산책',
          // relevanceScore: 0.8,
          icon: Icons.directions_walk,
        ),
      ];

      return Result.success('제안 질문 로드 완료', suggestions);
    } catch (e) {
      return Result.failure('제안 질문 가져오기 실패: $e');
    }
  }

  /// 메시지에서 주제 추출
  List<String> _extractTopics(String message) {
    final topics = <String>[];

    if (message.contains('건강') || message.contains('병원')) {
      topics.add('건강');
    }
    if (message.contains('산책') || message.contains('운동')) {
      topics.add('산책');
    }
    if (message.contains('먹이') || message.contains('음식')) {
      topics.add('급식');
    }

    return topics.isEmpty ? ['일반'] : topics;
  }
}
