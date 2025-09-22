/// 🎭 Mock Data 통합 Index
///
/// 모든 Mock 서비스와 데이터를 중앙 집중식으로 관리
/// 프로덕션 배포 시 mock_data/ 폴더 전체를 삭제하면 완전 제거됩니다.
library;

// === Core Mock Infrastructure ===
export 'core/base_mock_service.dart';

// === Feature Mock Services ===
export 'features/ai/ai_mock_service.dart';
export 'features/auth/auth_mock_service.dart';
export 'features/facility/facility_mock_service.dart';
export 'features/home/home_mock_service.dart';
export 'features/notification/notification_mock_service.dart';
export 'features/pet/pet_mock_service.dart';
export 'features/pet_activities/pet_activities_mock_service.dart';
export 'features/pet_feeding/pet_feeding_mock_service.dart';
export 'features/pet_health/pet_health_mock_service.dart';
export 'features/scheduling/scheduling_mock_service.dart';
export 'features/walk/walk_mock_service.dart';

// === Mockito Integration (프로덕션에서 삭제됨) ===
export 'mockito/providers/mockito_environment_helper.dart';
export 'mockito/test_mockito_integration.dart';

// === Test Utilities ===
export 'test/test_data_helper.dart';
export 'test/test_mock_service.dart';