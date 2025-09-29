/// 공유 도메인 모듈
///
/// 여러 기능에서 공통으로 사용하는 도메인 엔티티와 값 객체를 제공합니다.
/// 기능 간 순환 참조를 방지하고 코드 재사용성을 높입니다.
library;

// Repository 인터페이스
// export '../domain/repositories/settings_repository.dart'; // 각 feature에서 자체 관리
// 엔티티
export 'entities/pet_entity.dart';

// 결과 패턴
export 'result.dart';

// 값 객체 (향후 확장)
// export 'value_objects/pet_id.dart';
// export 'value_objects/user_id.dart';

// 공통 도메인 서비스 (향후 확장)
// export 'services/pet_validation_service.dart';
// export 'services/date_calculation_service.dart';
