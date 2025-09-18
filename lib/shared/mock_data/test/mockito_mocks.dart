import 'package:mockito/annotations.dart';

import '../../../features/ai/domain/repositories/ai_repository.dart';
import '../../../features/home/domain/repositories/home_repository.dart';
import '../../../features/pet_registor/domain/repositories/pet_repository.dart';

/// Mockito 어노테이션을 사용하여 Mock 클래스 생성을 위한 설정
///
/// 이 파일을 수정한 후 다음 명령어를 실행하여 Mock 클래스를 생성합니다:
/// ```bash
/// flutter packages pub run build_runner build --delete-conflicting-outputs
/// ```
@GenerateMocks([
  // Repository Mocks (가장 중요 - 테스트에서 실제로 사용됨)
  AiRepository,
  HomeRepository,
  PetRepository,
])
void main() {
  // Mock 클래스 생성을 위한 더미 main 함수
}