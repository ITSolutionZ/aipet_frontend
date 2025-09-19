import 'package:aipet_frontend/features/ai/data/services/openai_service.dart';
// AI Feature
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
// Auth Feature (Firebase Auth는 실제 API 사용)
import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
// Home Feature (Weather API는 실제 API 사용)
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
// Pet Feature
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
// Walk Feature (Google Maps는 실제 API 사용)
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/features/walk/domain/services/walk_route_service.dart';
import 'package:aipet_frontend/shared/services/common_error_service.dart';
import 'package:aipet_frontend/shared/services/ui_service.dart';
// Shared Services
import 'package:aipet_frontend/shared/services/validation_service.dart';
import 'package:mockito/annotations.dart';

/// Mockito 어노테이션을 사용하여 Mock 클래스 생성을 위한 설정
///
/// 실제 API가 있는 서비스들은 제외:
/// - Google Maps (google_maps_flutter)
/// - Weather API (OpenWeatherMap)
/// - Firebase Auth (firebase_auth)
/// - OpenAI API (openai_service.dart의 실제 API 부분)
///
/// 이 파일을 수정한 후 다음 명령어를 실행하여 Mock 클래스를 생성합니다:
/// ```bash
/// dart run build_runner build --delete-conflicting-outputs
/// ```
@GenerateMocks([
  // AI Feature
  AiRepository,
  OpenAIService,

  // Auth Feature (Firebase Auth는 실제 API 사용하므로 제외)
  AuthRepository,

  // Home Feature (Weather API는 실제 API 사용하므로 제외)
  HomeRepository,

  // Pet Features
  PetRepository,

  // Walk Feature (Google Maps는 실제 API 사용하므로 제외)
  WalkRepository,
  WalkRouteService,

  // Shared Services
  ValidationService,
  CommonErrorService,
  UiService,
])
void main() {
  // Mock 클래스 생성을 위한 더미 main 함수
}
