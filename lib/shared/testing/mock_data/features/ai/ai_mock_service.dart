import 'package:aipet_frontend/features/ai/ai.dart';
import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';

/// AI Feature 전용 Mock 데이터 서비스
class AiMockService extends BaseMockService {
  // ==================== AI 채팅 데이터 ====================

  /// Mock AI 채팅 히스토리
  static List<AiMessageEntity> getMockAiChatHistory() {
    return [
      AiMessageEntity(
        id: MockHelper.generateId(),
        content: '안녕하세요! MAX에 대해 궁금한 것이 있으시면 언제든지 물어보세요.',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        petId: '1',
      ),
      AiMessageEntity(
        id: MockHelper.generateId(),
        content: 'MAX가 요즘 식욕이 없어 보이는데 어떻게 해야 할까요?',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        petId: '1',
      ),
      AiMessageEntity(
        id: MockHelper.generateId(),
        content:
            '펫의 식욕 부진은 여러 원인이 있을 수 있습니다. 다음과 같은 점들을 확인해보세요:\n\n1. 환경 변화나 스트레스\n2. 사료 변경\n3. 건강 상태\n\n만약 2-3일 지속된다면 수의사 상담을 권합니다.',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        petId: '1',
        metadata: {'confidence': 0.85, 'category': '건강상담'},
      ),
    ];
  }

  /// Mock AI 채팅 세션 목록
  static List<AiChatSessionEntity> getMockAiChatSessions() {
    return [
      AiChatSessionEntity(
        id: MockHelper.generateId(),
        title: 'MAX 식욕 부진 상담',
        messages: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        petId: '1',
        petName: 'MAX',
      ),
      AiChatSessionEntity(
        id: MockHelper.generateId(),
        title: 'LUNA 산책 훈련 방법',
        messages: [],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        petId: '2',
        petName: 'LUNA',
      ),
      AiChatSessionEntity(
        id: MockHelper.generateId(),
        title: 'MOMO 고양이 놀이',
        messages: [],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        petId: '3',
        petName: 'MOMO',
      ),
    ];
  }

  /// Mock 추천 질문 목록
  static List<Map<String, dynamic>> getMockAiSuggestedQuestions() {
    return [
      {
        'id': MockHelper.generateId(),
        'question': '우리 강아지가 계속 짖는 이유가 뭘까요?',
        'category': '행동',
        'icon': '🐕',
        'popularity': 95,
      },
      {
        'id': MockHelper.generateId(),
        'question': '고양이 화장실 훈련 방법을 알려주세요',
        'category': '훈련',
        'icon': '🐱',
        'popularity': 87,
      },
      {
        'id': MockHelper.generateId(),
        'question': '펫 사료 바꿀 때 주의사항이 있나요?',
        'category': '영양',
        'icon': '🍽️',
        'popularity': 82,
      },
      {
        'id': MockHelper.generateId(),
        'question': '예방접종 일정을 어떻게 관리해야 하나요?',
        'category': '건강',
        'icon': '💉',
        'popularity': 76,
      },
      {
        'id': MockHelper.generateId(),
        'question': '펫과 함께하는 운동 방법',
        'category': '운동',
        'icon': '🏃',
        'popularity': 71,
      },
    ];
  }

  /// 카테고리별 추천 질문 조회
  static List<Map<String, dynamic>> getMockSuggestedQuestionsByCategory(String category) {
    final allQuestions = getMockAiSuggestedQuestions();
    return allQuestions.where((q) => q['category'] == category).toList();
  }

  // ==================== AI 응답 시뮬레이션 ====================

  /// Mock AI 응답 생성
  static Future<AiMessageEntity> mockAiResponse({
    required String userMessage,
    required String petId,
  }) async {
    await MockHelper.simulateApiCall();

    // 간단한 키워드 기반 응답
    final response = _generateMockResponse(userMessage);

    return AiMessageEntity(
      id: MockHelper.generateId(),
      content: response,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      petId: petId,
      metadata: {
        'confidence': 0.80 + (DateTime.now().millisecond % 20) * 0.01,
        'responseTime': DateTime.now().millisecond % 1000 + 500,
        'model': 'pet-assistant-v1',
      },
    );
  }

  /// 키워드 기반 Mock 응답 생성
  static String _generateMockResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('식욕') || message.contains('밥') || message.contains('사료')) {
      return '펫의 식욕 변화는 다양한 원인이 있을 수 있습니다. 스트레스, 환경 변화, 건강 상태 등을 확인해보시고, 지속될 경우 수의사 상담을 받아보세요.';
    } else if (message.contains('산책') || message.contains('운동')) {
      return '규칙적인 산책은 펫의 건강에 매우 중요합니다. 펫의 나이와 크기에 맞는 적절한 운동량을 유지하시고, 날씨가 너무 덥거나 추울 때는 주의해주세요.';
    } else if (message.contains('훈련') || message.contains('트릭')) {
      return '펫 훈련은 인내심과 일관성이 중요합니다. 짧고 빈번한 세션으로 시작하고, 성공할 때마다 즉시 보상을 주세요. 긍정적 강화가 가장 효과적입니다.';
    } else if (message.contains('건강') || message.contains('병원') || message.contains('아프')) {
      return '펫의 건강 이상 징후가 보이면 빠른 시일 내에 수의사와 상담하는 것이 좋습니다. 예방이 치료보다 중요하니 정기 검진도 잊지 마세요.';
    } else if (message.contains('고양이') || message.contains('cat')) {
      return '고양이는 독립적인 성격을 가지고 있으며, 개와는 다른 관리 방법이 필요합니다. 깨끗한 화장실, 수직 공간, 적절한 놀이 시간을 제공해주세요.';
    } else if (message.contains('강아지') || message.contains('개') || message.contains('dog')) {
      return '강아지는 사회적 동물로 꾸준한 관심과 훈련이 필요합니다. 적절한 사회화, 규칙적인 산책, 그리고 일관된 훈련을 통해 건강하고 행복한 반려견으로 키울 수 있습니다.';
    } else {
      return '반려동물에 대한 질문을 해주셔서 감사합니다. 더 구체적인 정보를 주시면 더 정확한 답변을 드릴 수 있어요. 언제든지 궁금한 것이 있으시면 물어보세요!';
    }
  }

  // ==================== 즐겨찾기 및 북마크 ====================

  /// Mock 즐겨찾는 메시지 목록
  static List<AiMessageEntity> getMockFavoriteMessages() {
    return [
      AiMessageEntity(
        id: MockHelper.generateId(),
        content: '펫의 식욕 부진은 여러 원인이 있을 수 있습니다. 다음과 같은 점들을 확인해보세요...',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        petId: '1',
        metadata: {'category': '건강상담', 'usefulness': 'high', 'isFavorite': true},
      ),
      AiMessageEntity(
        id: MockHelper.generateId(),
        content: '작은 개 산책 시 주의사항: 1. 적절한 거리 조절 2. 더운 아스팔트 주의 3. 다른 개와의 만남 시 주의',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        petId: '2',
        metadata: {'category': '산책가이드', 'usefulness': 'high', 'isFavorite': true},
      ),
    ];
  }

  /// 즐겨찾기 추가/제거
  static Future<Map<String, dynamic>> mockToggleFavorite({
    required String messageId,
    required bool isFavorite,
  }) async {
    await MockHelper.simulateApiCall();

    return {
      'success': true,
      'messageId': messageId,
      'isFavorite': isFavorite,
      'message': isFavorite ? '즐겨찾기에 추가했습니다' : '즐겨찾기에서 제거했습니다',
    };
  }

  // ==================== AI 설정 및 개인화 ====================

  /// Mock AI 설정 정보
  static Map<String, dynamic> getMockAiSettings() {
    return {
      'responseStyle': 'detailed', // detailed, concise, friendly
      'preferredLanguage': 'ko',
      'includeReferences': true,
      'personalizedRecommendations': true,
      'dataUsageConsent': true,
      'responseSpeed': 'normal', // fast, normal, thoughtful
      'expertiseAreas': ['건강', '영양', '훈련', '행동'],
      'notificationSettings': {'newTips': true, 'weeklyDigest': true, 'urgentAlerts': true},
    };
  }

  /// AI 설정 업데이트
  static Future<Map<String, dynamic>> mockUpdateAiSettings({
    required Map<String, dynamic> settings,
  }) async {
    await MockHelper.simulateApiCall();

    return {
      'success': true,
      'settings': {...getMockAiSettings(), ...settings},
      'message': '설정이 업데이트되었습니다',
    };
  }

  // ==================== 분석 및 통계 ====================

  /// Mock AI 사용 통계
  static Map<String, dynamic> getMockAiUsageStats() {
    return {
      'totalMessages': 156,
      'totalSessions': 23,
      'averageSessionLength': const Duration(minutes: 8),
      'mostUsedCategories': [
        {'category': '건강', 'count': 45, 'percentage': 28.8},
        {'category': '훈련', 'count': 38, 'percentage': 24.4},
        {'category': '영양', 'count': 31, 'percentage': 19.9},
        {'category': '행동', 'count': 25, 'percentage': 16.0},
        {'category': '기타', 'count': 17, 'percentage': 10.9},
      ],
      'satisfactionScore': 4.2, // 5점 만점
      'helpfulnessRating': 87, // 퍼센트
      'responseTimeAverage': const Duration(milliseconds: 1200),
      'lastWeekActivity': [
        const {'day': 'Mon', 'messages': 8},
        const {'day': 'Tue', 'messages': 12},
        const {'day': 'Wed', 'messages': 6},
        const {'day': 'Thu', 'messages': 15},
        const {'day': 'Fri', 'messages': 10},
        const {'day': 'Sat', 'messages': 4},
        const {'day': 'Sun', 'messages': 7},
      ],
    };
  }

  /// 주간 AI 팁
  static List<Map<String, dynamic>> getMockWeeklyTips() {
    return [
      {
        'id': MockHelper.generateId(),
        'title': '겨울철 펫 관리법',
        'content': '추운 겨울에는 펫의 피부가 건조해지기 쉽습니다. 실내 습도를 적절히 유지하고...',
        'category': '건강',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': false,
      },
      {
        'id': MockHelper.generateId(),
        'title': '펫과 함께하는 실내 운동',
        'content': '날씨가 좋지 않을 때는 실내에서도 충분히 운동할 수 있습니다. 계단 오르기, 공 던지기...',
        'category': '운동',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
      },
    ];
  }
}
