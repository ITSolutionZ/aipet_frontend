import 'package:flutter/material.dart';

import '../../features/pet_registor/domain/entities/pet_profile_entity.dart';
import '../constants/ai_constants.dart';

/// AI 기능 전용 로거 유틸리티
class AiLogger {
  /// API 호출 시작 로그
  static void logApiStart(String message, {String? context}) {
    final contextText = context != null ? ' ($context)' : '';
    debugPrint('${AiConstants.apiCallStartMessage}$contextText: $message');
  }

  /// API 응답 성공 로그
  static void logApiSuccess(String response) {
    final truncatedResponse =
        response.length > AiConstants.maxResponseLengthForLog
        ? '${response.substring(0, AiConstants.maxResponseLengthForLog)}...'
        : response;
    debugPrint('${AiConstants.apiResponseSuccessMessage}: $truncatedResponse');
  }

  /// API 호출 실패 로그
  static void logApiError(dynamic error) {
    debugPrint('${AiConstants.apiCallFailureMessage}: $error');
  }

  /// 펫 컨텍스트 정보 로그
  static void logPetContext(String? petName, String? petType) {
    if (petName != null && petType != null) {
      debugPrint('   ${AiConstants.petContextMessage}$petName ($petType)');
    }
  }

  /// 펫 컨텍스트와 함께 API 호출 시작 로그
  static void logApiStartWithPet(String message, PetProfileEntity? petContext) {
    logApiStart(message, context: '펫 컨텍스트');
    if (petContext != null) {
      logPetContext(petContext.name, petContext.typeName);
    }
  }
}
