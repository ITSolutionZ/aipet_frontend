// Entity imports
import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_history_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_summary.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/ai/ai_mock_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/home/home_mock_service.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_data.dart';

import 'test_mock_service.dart';

/// 기존 테스트를 Mock 데이터로 전환하기 위한 헬퍼 클래스
///
/// 기존 테스트에서 사용하던 하드코딩된 데이터를
/// 중앙화된 Mock 서비스로 대체하는 것을 도와줍니다.
class TestDataHelper {
  // ==================== AI 관련 테스트 데이터 ====================

  /// AI 채팅 요약 테스트 데이터
  static AiChatSummary get aiChatSummary =>
      TestMockService.createMockAiChatSummary();

  /// AI 메시지 테스트 데이터
  static AiMessageEntity get aiMessage =>
      TestMockService.createMockAiMessageEntity();

  /// AI 카테고리 테스트 데이터
  static AiCategoryEntity get aiCategory =>
      TestMockService.createMockAiCategoryEntity();

  /// AI 채팅 히스토리 테스트 데이터
  static AiChatHistoryEntity get aiChatHistory =>
      TestMockService.createMockAiChatHistoryEntity();

  /// AI 즐겨찾기 QA 테스트 데이터
  static AiFavoriteQaEntity get aiFavoriteQa =>
      TestMockService.createMockAiFavoriteQaEntity();

  /// 여러 AI 메시지 목록 테스트 데이터
  static List<AiMessageEntity> getAiMessageList({int count = 5}) =>
      TestMockService.createMockMessageList(count: count);

  // ==================== Home 관련 테스트 데이터 ====================

  /// 펫 요약 테스트 데이터
  static PetSummaryEntity get petSummary =>
      TestMockService.createMockPetSummaryEntity();

  /// 날씨 테스트 데이터
  static WeatherEntity get weather => TestMockService.createMockWeatherEntity();

  /// 날씨 위치 테스트 데이터
  static WeatherLocationEntity get weatherLocation =>
      TestMockService.createMockWeatherLocationEntity();

  /// 약속 요약 테스트 데이터
  static AppointmentSummary get appointmentSummary =>
      TestMockService.createMockAppointmentSummary();

  /// 건강 알림 테스트 데이터
  static HealthAlert get healthAlert => TestMockService.createMockHealthAlert();

  /// 건강 요약 테스트 데이터
  static HealthSummary get healthSummary =>
      TestMockService.createMockHealthSummary();

  /// 산책 요약 테스트 데이터
  static WalkSummary get walkSummary => TestMockService.createMockWalkSummary();

  /// 홈 대시보드 테스트 데이터
  static HomeDashboardEntity get homeDashboard =>
      TestMockService.createMockHomeDashboardEntity();

  /// 여러 펫 목록 테스트 데이터
  static List<PetSummaryEntity> getPetList({int count = 3}) =>
      TestMockService.createMockPetList(count: count);

  /// 여러 건강 알림 목록 테스트 데이터
  static List<HealthAlert> getHealthAlertList({int count = 5}) =>
      TestMockService.createMockHealthAlertList(count: count);

  // ==================== Pet Profile 관련 테스트 데이터 ====================

  /// 펫 프로필 테스트 데이터
  static PetProfileEntity get petProfile =>
      TestMockService.createMockPetProfileEntity();

  /// 여러 펫 프로필 목록 - 기존 mock_data에서 가져오기
  static List<PetProfileEntity> get petProfiles => PetMockData.getMockPets();

  /// 강아지 품종 목록 테스트 데이터
  static List<String> get dogBreeds => PetMockData.getMockDogBreeds()
      .map((breed) => breed['name'] as String)
      .toList();

  /// 고양이 품종 목록 테스트 데이터
  static List<String> get catBreeds => PetMockData.getMockCatBreeds()
      .map((breed) => breed['name'] as String)
      .toList();

  // ==================== 기존 Mock 서비스와의 연동 ====================

  /// Home Mock 서비스 데이터 접근
  static Type get homeMock => HomeMockService;

  /// AI Mock 데이터 접근
  static Type get aiMock => AiMockService;

  /// Pet Mock 데이터 접근
  static Type get petMock => PetMockData;

  // ==================== 테스트용 ID 생성 헬퍼 ====================

  /// 테스트용 고유 ID 생성
  static String generateTestId([String? prefix]) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix ?? 'test'}-$timestamp';
  }

  /// 테스트용 날짜 생성 헬퍼
  static DateTime generateTestDate({int daysAgo = 0}) {
    return DateTime.now().subtract(Duration(days: daysAgo));
  }

  // ==================== 기존 테스트 패턴 지원 ====================

  /// setUp에서 사용할 표준 테스트 데이터 세트
  static Map<String, dynamic> getStandardTestData() {
    return {
      'aiChatSummary': aiChatSummary,
      'petSummary': petSummary,
      'weather': weather,
      'petProfile': petProfile,
      'homeDashboard': homeDashboard,
    };
  }

  /// 특정 기능별 테스트 데이터 세트
  static Map<String, dynamic> getAiTestData() {
    return {
      'summary': aiChatSummary,
      'message': aiMessage,
      'category': aiCategory,
      'chatHistory': aiChatHistory,
      'favoriteQa': aiFavoriteQa,
      'messageList': getAiMessageList(),
    };
  }

  static Map<String, dynamic> getHomeTestData() {
    return {
      'petSummary': petSummary,
      'weather': weather,
      'dashboard': homeDashboard,
      'appointments': appointmentSummary,
      'healthSummary': healthSummary,
      'walkSummary': walkSummary,
      'petList': getPetList(),
    };
  }

  static Map<String, dynamic> getPetTestData() {
    return {
      'profile': petProfile,
      'profiles': petProfiles,
      'dogBreeds': dogBreeds,
      'catBreeds': catBreeds,
    };
  }
}

/// 테스트에서 자주 사용하는 값들의 상수
class TestConstants {
  // 테스트용 날짜
  static final DateTime testDate = DateTime(2024, 1, 1, 12, 0);
  static final DateTime testBirthDate = DateTime(2021, 1, 1);
  static final DateTime testCreatedAt = DateTime(2021, 1, 1);

  // 테스트용 ID들
  static const String testPetId = 'pet-1';
  static const String testOwnerId = 'owner-1';
  static const String testChatId = 'chat-1';
  static const String testMessageId = 'msg-1';
  static const String testCategoryId = 'health';

  // 테스트용 텍스트
  static const String testPetName = 'テストペット';
  static const String testBreed = '柴犬';
  static const String testLocation = '東京';
  static const String testTitle = 'ペットの健康相談';
  static const String testContent = 'ペットの健康管理について相談した内容';
}
