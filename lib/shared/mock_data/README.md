# Mock Data Service

이 디렉토리는 앱 전반에 걸쳐 사용되는 목 데이터를 중앙에서 관리합니다.

## 개요

`MockDataService`는 앱의 모든 목 데이터를 한 곳에서 관리하여 추후 실제 API로 전환할 때 쉽게 제거할 수 있도록 설계되었습니다.

## 사용 방법

### 목 데이터 활성화/비활성화

`MockDataService.isEnabled` 플래그를 변경하여 목 데이터 사용을 제어할 수 있습니다:

```dart
// mock_data_service.dart
abstract class MockDataService {
  /// true: 목 데이터 사용
  /// false: 실제 API 호출
  static const bool isEnabled = true;
}
```

### 실제 API로 전환하기

1. `MockDataService.isEnabled`를 `false`로 변경
2. 또는 mock_data 폴더 전체를 삭제하고 관련 import문들을 제거

## 지원하는 기능

### Pet Activities (펫 액티비티)

- `getMockTricks()`: 트릭 목록 데이터
- `getMockVideoBookmarks()`: 비디오 북마크 데이터
- `getMockVideoProgress()`: 비디오 진행도 데이터

### Pet Feeding (펫 급여)

- `getMockRecipes()`: 레시피 목록 데이터
- `getRecipesByDifficulty(String difficulty)`: 난이도별 레시피 필터링
- `getFavoriteRecipes()`: 즐겨찾기 레시피만 가져오기
- `searchRecipes(String query)`: 검색어로 레시피 필터링
- `getRecipeById(String id)`: ID로 레시피 가져오기
- `getTopRatedRecipes({int limit = 5})`: 최고 평점 레시피 가져오기
- `getQuickRecipes()`: 빠른 조리 레시피 가져오기 (30분 이하)
- `getMockFeedingRecords()`: 급여 기록 데이터
- `getMockFeedingStatistics()`: 급여 통계 데이터
- `getMockFeedingSchedules()`: 식사 스케줄 데이터
- `updateFeedingSchedule(String mealType, String time, String amount)`: 식사 스케줄 업데이트
- `addMockFeedingRecord(Map<String, dynamic> record)`: 새로운 급여 기록 추가
- `getMockFeedingRecordsWithNew()`: 새로 추가된 기록을 포함한 급여 기록 데이터

### Scheduling Screens (스케줄링 화면들)

- `getMockTodayMealsForSchedule()`: 오늘의 급여 상태 (스케줄 화면용)
- `getMockFeedingSchedulesForSchedule()`: 급여 스케줄 (스케줄 화면용)
- `getMockFeedingStatisticsForRecords()`: 급여 통계 (기록 화면용)
- `getMockFeedingRecordsForRecords()`: 급여 기록 (기록 화면용)
- `getMockFeedingAnalysisData()`: 급여 분석 데이터 (분석 화면용)
- `getMockWateringData()`: 급수 관련 데이터 (급수 화면용)
- `getMockTrainingData()`: 트레이닝 관련 데이터 (트레이닝 화면용)
- `getMockHealthData()`: 건강 관리 데이터 (건강 화면용)

### Pet Health (펫 건강)

- `getMockVaccineRecords()`: 백신 기록 데이터
- `getMockWeightRecords()`: 체중 기록 데이터

### Pet Profile (펫 프로필)

- `getMockPetProfiles()`: 펫 프로필 목록 데이터
- `getMockPets()`: 기본 펫 목록 데이터
- `getMockPetById(String id)`: 특정 펫 데이터

### Facility (시설)

- `getMockFacilities()`: 동물병원, 미용실 등의 시설 데이터

### Home Dashboard (홈 대시보드)

- `getMockWeather()`: 날씨 정보
- `getMockAppointments()`: 예정된 예약 정보
- `getMockHealthSummary()`: 반려동물 건강 요약
- `getMockWalkSummary()`: 산책 요약 정보
- `getMockPetProfiles()`: 반려동물 프로필 목록

### Notification (알림)

- `getMockNotifications()`: 알림 목록 데이터
- `getMockNotificationSettings()`: 알림 설정 데이터

### Walk (산책)

- `getMockWalkRecords()`: 산책 기록 데이터

### AI (인공지능)

- `getMockAiChatHistory()`: AI 채팅 기록 데이터
- `getMockAiChatSessions()`: AI 채팅 세션 데이터
- `getMockAiSuggestedQuestions()`: AI 추천 질문 데이터

## 적용된 Repository들

다음 Repository들이 MockDataService를 사용하도록 업데이트되었습니다:

- `PetActivitiesRepositoryImpl`: 트릭, 비디오 북마크, 비디오 진행도 관련 API 호출
- `PetFeedingRepositoryImpl`: 급여 기록 및 통계 관련 API 호출
- `PetHealthRepositoryImpl`: 백신 기록, 체중 기록 관련 API 호출
- `PetProfileRepositoryImpl`: 펫 프로필 관련 API 호출
- `FacilityRepositoryImpl`: 모든 시설 관련 API 호출
- `HomeRepositoryImpl`: 홈 대시보드 관련 API 호출
- `PetRepositoryImpl`: 메모리 기반 저장소 (목 데이터 비활성화 시 사용)
- `CalendarRepositoryImpl`: 메모리 기반 저장소 (목 데이터 비활성화 시 사용)
- `WalkRepositoryImpl`: 메모리 기반 저장소 (목 데이터 비활성화 시 사용)
- `NotificationRepositoryImpl`: 알림 관련 API 호출

## 새로운 목업 데이터 추가하기

1. `MockDataService`에 새로운 정적 메서드 추가:

   ```dart
   static List<YourEntity> getMockYourData() => [
     // 목 데이터 정의
   ];
   ```

2. Repository 구현체에서 사용:

   ```dart
   @override
   Future<List<YourEntity>> getYourData() async {
     if (MockDataService.isEnabled) {
       await Future.delayed(const Duration(milliseconds: 300));
       return MockDataService.getMockYourData();
     }

     // TODO: 실제 API 호출
     throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
   }
   ```

3. Repository 생성자에서 초기화:

   ```dart
   class YourRepositoryImpl implements YourRepository {
     late final List<YourEntity> _data;

     YourRepositoryImpl() {
       _data = List.from(MockDataService.getMockYourData());
     }
   }
   ```

## 주의사항

- 목 데이터 제거 시 모든 관련 import문들도 함께 제거해야 합니다
- Repository에서 `MockDataService.isEnabled` 체크를 빠뜨리지 않도록 주의하세요
- 실제 API 구현 시 `UnimplementedError` 대신 실제 API 호출 코드로 교체하세요
- 메모리 기반 저장소는 `MockDataService`의 데이터로 초기화하여 일관성을 유지합니다
