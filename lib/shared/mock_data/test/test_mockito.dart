import 'package:mockito/annotations.dart';

import '../../../features/ai/domain/repositories/ai_repository.dart';
import '../../../features/home/domain/repositories/home_repository.dart';
import '../../../features/pet_registor/domain/repositories/pet_repository.dart';

@GenerateMocks([AiRepository, HomeRepository, PetRepository])
void main() {
  // Mock 클래스 생성을 위한 더미 main 함수
}
