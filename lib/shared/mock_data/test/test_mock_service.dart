import '../../../features/ai/domain/entities/ai_category_entity.dart';
import '../../../features/ai/domain/entities/ai_chat_history_entity.dart';
import '../../../features/ai/domain/entities/ai_chat_summary.dart';
import '../../../features/ai/domain/entities/ai_favorite_qa_entity.dart';
import '../../../features/ai/domain/entities/ai_message_entity.dart';
import '../../../features/home/domain/entities/entities.dart';
import '../../../features/pet_registor/domain/entities/pet_profile_entity.dart';

/// 테스트 전용 Mock 데이터 서비스
///
/// 모든 엔티티의 Mock 인스턴스를 제공하며,
/// 테스트에서 일관되게 사용할 수 있는 표준화된 테스트 데이터를 제공합니다.
class TestMockService {
  // ==================== AI Feature Mock Data ====================

  /// Mock AiChatSummary 생성
  static AiChatSummary createMockAiChatSummary({
    String? title,
    String? content,
  }) {
    return const AiChatSummary(
      title: 'ペットの健康相談',
      content: 'ペットの健康管理について相談し、定期的な健康診断と適切な食事の重要性について学びました。',
    );
  }

  /// Mock AiMessageEntity 생성
  static AiMessageEntity createMockAiMessageEntity({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    String? petId,
    String? petName,
  }) {
    return AiMessageEntity(
      id: id ?? 'msg-1',
      content: content ?? 'こんにちは',
      type: type ?? MessageType.user,
      timestamp: timestamp ?? DateTime(2024, 1, 1, 12, 0),
      petId: petId ?? 'pet-1',
      petName: petName ?? 'テストペット',
    );
  }

  /// Mock AiCategoryEntity 생성
  static AiCategoryEntity createMockAiCategoryEntity({
    String? id,
    String? name,
    String? description,
    dynamic icon,
    dynamic color,
  }) {
    return AiCategoryEntity(
      id: id ?? 'health',
      name: name ?? '健康管理',
      description: description ?? 'ペットの健康に関する質問',
      icon: icon ?? 'health_and_safety',
      color: color ?? 'red',
    );
  }

  /// Mock AiChatHistoryEntity 생성
  static AiChatHistoryEntity createMockAiChatHistoryEntity({
    String? id,
    String? title,
    String? summary,
    List<AiMessageEntity>? messages,
    PetProfileEntity? pet,
    AiCategoryEntity? category,
    DateTime? createdAt,
    bool? isManualSaved,
    int? messageCount,
  }) {
    final testMessages =
        messages ??
        [
          createMockAiMessageEntity(id: 'msg-1', content: 'こんにちは'),
          createMockAiMessageEntity(
            id: 'msg-2',
            content: 'こんにちは！どのようなことでお手伝いできますか？',
            type: MessageType.assistant,
          ),
        ];

    return AiChatHistoryEntity(
      id: id ?? 'chat-1',
      title: title ?? 'ペットの健康相談',
      summary: summary ?? 'ペットの健康について相談した内容',
      messages: testMessages,
      pet: pet ?? createMockPetProfileEntity(),
      category: category ?? createMockAiCategoryEntity(),
      createdAt: createdAt ?? DateTime(2024, 1, 1, 12, 0),
      isManualSaved: isManualSaved ?? true,
      messageCount: messageCount ?? testMessages.length,
    );
  }

  /// Mock AiFavoriteQaEntity 생성
  static AiFavoriteQaEntity createMockAiFavoriteQaEntity({
    String? id,
    String? question,
    String? answer,
    PetProfileEntity? pet,
    String? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? originalTimestamp,
  }) {
    return AiFavoriteQaEntity(
      id: id ?? 'fav-qa-1',
      question: question ?? '犬の健康について教えて',
      answer: answer ?? '犬の健康を保つためには...',
      pet: pet ?? createMockPetProfileEntity(),
      categoryId: categoryId ?? 'health',
      categoryName: categoryName ?? '健康管理',
      createdAt: createdAt ?? DateTime(2024, 1, 1, 12, 0),
      originalTimestamp: originalTimestamp ?? DateTime(2024, 1, 1, 10, 0),
    );
  }

  // ==================== Home Feature Mock Data ====================

  /// Mock PetSummaryEntity 생성
  static PetSummaryEntity createMockPetSummaryEntity({
    String? id,
    String? name,
    String? typeName,
    String? breed,
    int? age,
    DateTime? birthDate,
    DateTime? createdAt,
    String? profileImageUrl,
    Map<String, dynamic>? additionalInfo,
  }) {
    return PetSummaryEntity(
      id: id ?? 'pet-1',
      name: name ?? 'テストペット',
      typeName: typeName ?? 'dog',
      breed: breed ?? '柴犬',
      age: age ?? 3,
      birthDate: birthDate ?? DateTime(2021, 1, 1),
      createdAt: createdAt ?? DateTime(2021, 1, 1),
      profileImageUrl: profileImageUrl ?? '/path/to/image.jpg',
      additionalInfo: additionalInfo ?? {'color': 'brown', 'weight': 10.5},
    );
  }

  /// Mock WeatherEntity 생성
  static WeatherEntity createMockWeatherEntity({
    double? temperature,
    String? location,
    int? weatherId,
    String? description,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    String? iconCode,
    double? uvIndex,
    int? visibility,
    double? pressure,
  }) {
    return WeatherEntity(
      temperature: temperature ?? 25.0,
      location: location ?? '東京',
      weatherId: weatherId ?? 800,
      description: description ?? '晴れ',
      feelsLike: feelsLike ?? 27.0,
      humidity: humidity ?? 60,
      windSpeed: windSpeed ?? 5.0,
      iconCode: iconCode ?? '01d',
      uvIndex: uvIndex ?? 6.0,
      visibility: visibility ?? 10000,
      pressure: pressure ?? 1013.25,
    );
  }

  /// Mock WeatherLocationEntity 생성
  static WeatherLocationEntity createMockWeatherLocationEntity({
    double? latitude,
    double? longitude,
    String? name,
  }) {
    return WeatherLocationEntity(
      latitude: latitude ?? 35.6762,
      longitude: longitude ?? 139.6503,
      name: name ?? '東京',
    );
  }

  /// Mock AppointmentSummary 생성
  static AppointmentSummary createMockAppointmentSummary({
    String? id,
    String? title,
    DateTime? scheduledTime,
    String? type,
    String? petName,
  }) {
    return AppointmentSummary(
      id: id ?? 'appointment-1',
      title: title ?? '健康診断',
      scheduledTime: scheduledTime ?? DateTime(2024, 1, 15, 14, 30),
      type: type ?? 'health_check',
      petName: petName ?? 'テストペット',
    );
  }

  /// Mock HealthAlert 생성
  static HealthAlert createMockHealthAlert({String? petName, String? message}) {
    return HealthAlert(
      petName: petName ?? 'テストペット',
      message: message ?? 'ワクチン接種が必要です',
    );
  }

  /// Mock HealthSummary 생성
  static HealthSummary createMockHealthSummary({
    int? totalPets,
    int? healthyPets,
    int? petsNeedingAttention,
    List<HealthAlert>? alerts,
  }) {
    return HealthSummary(
      totalPets: totalPets ?? 5,
      healthyPets: healthyPets ?? 3,
      petsNeedingAttention: petsNeedingAttention ?? 2,
      alerts:
          alerts ??
          [
            createMockHealthAlert(petName: 'ペット1', message: '健康診断が必要です'),
            createMockHealthAlert(petName: 'ペット2', message: 'ワクチン接種が必要です'),
          ],
    );
  }

  /// Mock WalkSummary 생성
  static WalkSummary createMockWalkSummary({
    int? todayWalks,
    double? todayDistance,
    Duration? todayDuration,
    double? weeklyGoal,
    double? weeklyProgress,
  }) {
    return WalkSummary(
      todayWalks: todayWalks ?? 3,
      todayDistance: todayDistance ?? 2.5,
      todayDuration: todayDuration ?? const Duration(hours: 1, minutes: 30),
      weeklyGoal: weeklyGoal ?? 20.0,
      weeklyProgress: weeklyProgress ?? 15.0,
    );
  }

  /// Mock HomeDashboardEntity 생성
  static HomeDashboardEntity createMockHomeDashboardEntity({
    String? currentTime,
    WeatherEntity? weather,
    List<PetSummaryEntity>? petProfiles,
    List<AppointmentSummary>? upcomingAppointments,
    HealthSummary? petHealthSummary,
    WalkSummary? walkSummary,
  }) {
    return HomeDashboardEntity(
      currentTime: currentTime ?? '2024-01-01T10:00:00Z',
      weather: weather ?? createMockWeatherEntity(),
      petProfiles:
          petProfiles ??
          [
            createMockPetSummaryEntity(
              id: 'pet-1',
              name: 'テストペット1',
              typeName: 'dog',
              breed: '柴犬',
            ),
            createMockPetSummaryEntity(
              id: 'pet-2',
              name: 'テストペット2',
              typeName: 'cat',
              breed: 'アメリカンショートヘア',
            ),
          ],
      upcomingAppointments:
          upcomingAppointments ?? [createMockAppointmentSummary()],
      petHealthSummary: petHealthSummary ?? createMockHealthSummary(),
      walkSummary: walkSummary ?? createMockWalkSummary(),
    );
  }

  // ==================== Pet Registration Mock Data ====================

  /// Mock PetProfileEntity 생성
  static PetProfileEntity createMockPetProfileEntity({
    String? id,
    String? name,
    String? type,
    String? breed,
    DateTime? birthDate,
    int? age,
    String? gender,
    double? weight,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imagePath,
    bool? isActive,
    Map<String, dynamic>? additionalInfo,
  }) {
    return PetProfileEntity(
      id: id ?? 'pet-1',
      name: name ?? 'テストペット',
      type: type ?? 'dog',
      breed: breed ?? 'ゴールデンレトリバー',
      birthDate: birthDate ?? DateTime(2020, 1, 1),
      age: age ?? 4,
      gender: gender ?? 'male',
      weight: weight ?? 15.8,
      ownerId: ownerId ?? 'owner-1',
      createdAt: createdAt ?? DateTime(2020, 1, 1),
      updatedAt: updatedAt ?? DateTime(2020, 1, 1),
      imagePath: imagePath ?? '/path/to/image.jpg',
      isActive: isActive ?? true,
      additionalInfo:
          additionalInfo ??
          {'gender': 'male', 'weight': 15.8, 'isNeutered': false},
    );
  }

  // ==================== 복수 Mock 데이터 생성 헬퍼 메서드 ====================

  /// 여러 Mock AiMessageEntity 생성
  static List<AiMessageEntity> createMockMessageList({
    int count = 5,
    String? basePetId,
    String? basePetName,
  }) {
    return List.generate(count, (index) {
      return createMockAiMessageEntity(
        id: 'msg-$index',
        content: 'メッセージ $index',
        type: index % 2 == 0 ? MessageType.user : MessageType.assistant,
        petId: basePetId ?? 'pet-1',
        petName: basePetName ?? 'テストペット',
      );
    });
  }

  /// 여러 Mock PetSummaryEntity 생성
  static List<PetSummaryEntity> createMockPetList({int count = 3}) {
    return List.generate(count, (index) {
      return createMockPetSummaryEntity(
        id: 'pet-$index',
        name: 'ペット$index',
        typeName: index % 2 == 0 ? 'dog' : 'cat',
        breed: index % 2 == 0 ? '柴犬' : 'アメリカンショートヘア',
        age: index + 1,
      );
    });
  }

  /// 여러 Mock HealthAlert 생성
  static List<HealthAlert> createMockHealthAlertList({int count = 5}) {
    return List.generate(count, (index) {
      return createMockHealthAlert(petName: 'ペット$index', message: 'アラート$index');
    });
  }
}
