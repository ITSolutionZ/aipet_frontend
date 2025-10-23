import 'dart:convert';

import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../entities/ai_category_entity.dart';
import '../entities/ai_message_entity.dart';

/// 🎯 AI 채팅 상태 영속화 관리자
///
/// 채팅 상태의 저장과 복원을 전담하는 서비스
class AiChatStatePersistence {
  // ✅ CacheService 사용
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }

  static const String _keyPrefix = 'ai_chat_state_';
  static const String _keySelectedPet = 'selected_pet_id';
  static const String _keySelectedCategory = 'selected_category_id';
  static const String _keyDraftMessage = 'draft_message';
  static const String _keyRecentMessages = 'recent_messages';

  /// ✅ 선택된 펫 저장
  Future<Result<void>> saveSelectedPet(String petId) async {
    try {
      await _init();
      await _cache.setString('$_keyPrefix$_keySelectedPet', petId);

      if (kDebugMode) {
        LoggerService.debug('💾 Selected pet saved: $petId');
      }
      return Result.success('펫 선택 상태가 저장되었습니다', null);
    } catch (e) {
      LoggerService.debug('❌ Failed to save selected pet: $e');
      return Result.failure('펫 저장 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 선택된 펫 로드
  Future<Result<String?>> loadSelectedPetId() async {
    try {
      await _init();
      final petId = _cache.getString('$_keyPrefix$_keySelectedPet');

      return Result.success('펫 선택 상태를 불러왔습니다', petId);
    } catch (e) {
      LoggerService.debug('❌ Failed to load selected pet: $e');
      return Result.failure('펫 로드 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 선택된 카테고리 저장
  Future<Result<void>> saveSelectedCategory(AiCategoryEntity? category) async {
    try {
      await _init();

      if (category == null) {
        await _cache.removeKey('$_keyPrefix$_keySelectedCategory');
      } else {
        final categoryJson = jsonEncode({
          'id': category.id,
          'name': category.name,
          'description': category.description,
        });
        await _cache.setString(
          '$_keyPrefix$_keySelectedCategory',
          categoryJson,
        );
      }

      if (kDebugMode) {
        LoggerService.debug(
          '💾 Selected category saved: ${category?.name ?? 'none'}',
        );
      }

      return Result.success('카테고리 선택 상태가 저장되었습니다', null);
    } catch (e) {
      LoggerService.debug('❌ Failed to save selected category: $e');
      return Result.failure('카테고리 저장 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 선택된 카테고리 로드
  Future<Result<AiCategoryEntity?>> loadSelectedCategory() async {
    try {
      await _init();
      final categoryJson = _cache.getString('$_keyPrefix$_keySelectedCategory');

      if (categoryJson == null) {
        return Result.success('저장된 카테고리가 없습니다', null);
      }

      final categoryMap = jsonDecode(categoryJson) as Map<String, dynamic>;
      final category = AiCategoryEntity(
        id: categoryMap['id'] as String,
        name: categoryMap['name'] as String,
        description: categoryMap['description'] as String? ?? '',
        icon: Icons.category,
        color: Colors.blue,
      );

      return Result.success('카테고리 선택 상태를 불러왔습니다', category);
    } catch (e) {
      LoggerService.debug('❌ Failed to load selected category: $e');
      return Result.failure('카테고리 로드 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 임시 메시지 저장 (작성 중인 메시지)
  Future<Result<void>> saveDraftMessage(String message) async {
    try {
      await _init();

      if (message.trim().isEmpty) {
        await _cache.removeKey('$_keyPrefix$_keyDraftMessage');
      } else {
        await _cache.setString('$_keyPrefix$_keyDraftMessage', message);
      }

      return Result.success('임시 메시지가 저장되었습니다', null);
    } catch (e) {
      LoggerService.debug('❌ Failed to save draft message: $e');
      return Result.failure('임시 메시지 저장 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 임시 메시지 로드
  Future<Result<String?>> loadDraftMessage() async {
    try {
      await _init();
      final draftMessage = _cache.getString('$_keyPrefix$_keyDraftMessage');

      return Result.success('임시 메시지를 불러왔습니다', draftMessage);
    } catch (e) {
      LoggerService.debug('❌ Failed to load draft message: $e');
      return Result.failure('임시 메시지 로드 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 최근 메시지 캐시 저장 (성능 최적화)
  Future<Result<void>> cacheRecentMessages(
    List<AiMessageEntity> messages, {
    int maxMessages = 20,
  }) async {
    try {
      await _init();

      // 최근 메시지만 캐시 (성능 고려)
      final recentMessages = messages.take(maxMessages).toList();
      final messagesJson = jsonEncode(
        recentMessages
            .map(
              (m) => {
                'id': m.id,
                'content': m.content,
                'timestamp': m.timestamp.toIso8601String(),
                'type': m.type.name,
              },
            )
            .toList(),
      );

      await _cache.setString('$_keyPrefix$_keyRecentMessages', messagesJson);

      if (kDebugMode) {
        LoggerService.debug(
          '💾 Cached ${recentMessages.length} recent messages',
        );
      }

      return Result.success('최근 메시지가 캐시되었습니다', null);
    } catch (e) {
      LoggerService.debug('❌ Failed to cache recent messages: $e');
      return Result.failure('메시지 캐시 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 캐시된 최근 메시지 로드
  Future<Result<List<AiMessageEntity>>> loadCachedMessages() async {
    try {
      await _init();
      final messagesJson = _cache.getString('$_keyPrefix$_keyRecentMessages');

      if (messagesJson == null) {
        return Result.success('캐시된 메시지가 없습니다', []);
      }

      final messagesList = jsonDecode(messagesJson) as List;
      final messages = messagesList.map((json) {
        final map = json as Map<String, dynamic>;
        return AiMessageEntity(
          id: map['id'] as String,
          content: map['content'] as String,
          timestamp: DateTime.parse(map['timestamp'] as String),
          type: MessageType.values.firstWhere(
            (t) => t.name == map['type'],
            orElse: () => MessageType.user,
          ),
        );
      }).toList();

      if (kDebugMode) {
        LoggerService.debug('📋 Loaded ${messages.length} cached messages');
      }

      return Result.success('캐시된 메시지를 불러왔습니다', messages);
    } catch (e) {
      LoggerService.debug('❌ Failed to load cached messages: $e');
      return Result.failure('캐시 메시지 로드 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 채팅 상태 초기화 (로그아웃, 앱 재설치 등)
  Future<Result<void>> clearAllChatState() async {
    try {
      await _init();

      // AI 채팅 관련 주요 키들 직접 삭제
      await _cache.removeKey('$_keyPrefix$_keySelectedPet');
      await _cache.removeKey('$_keyPrefix$_keySelectedCategory');
      await _cache.removeKey('$_keyPrefix$_keyDraftMessage');
      await _cache.removeKey('$_keyPrefix$_keyRecentMessages');

      if (kDebugMode) {
        LoggerService.debug(
          '🗑️ Cleared ${keysToRemove.length} chat state entries',
        );
      }

      return Result.success('채팅 상태가 초기화되었습니다', null);
    } catch (e) {
      LoggerService.debug('❌ Failed to clear chat state: $e');
      return Result.failure('채팅 상태 초기화 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 특정 펫의 채팅 상태만 삭제
  Future<Result<void>> clearPetChatState(String petId) async {
    try {
      await _init();
      await _cache.removeKey('$_keyPrefix${petId}_messages');
      await _cache.removeKey('$_keyPrefix${petId}_draft');

      if (kDebugMode) {
        LoggerService.debug('🗑️ Cleared chat state for pet: $petId');
      }

      return Result.success('펫 채팅 상태가 삭제되었습니다', null);
    } catch (e) {
      LoggerService.debug('❌ Failed to clear pet chat state: $e');
      return Result.failure('펫 채팅 상태 삭제 중 오류가 발생했습니다: $e');
    }
  }
}
