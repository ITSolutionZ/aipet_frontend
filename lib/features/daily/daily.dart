/// Daily Health Feature - Clean Architecture Implementation
///
/// 이 패키지는 일일 건강 관리 기능을 Clean Architecture 원칙에 따라 구현합니다.
///
/// ## 구조
/// - **Application**: 어댑터 및 서비스 조정
/// - **Domain**: 비즈니스 로직과 엔티티
/// - **Data**: 데이터 소스와 Repository 구현
/// - **Presentation**: UI와 상태 관리
///
/// ## 주요 특징
/// - Use Case 패턴으로 비즈니스 로직 캡슐화
/// - Repository 패턴으로 데이터 액세스 추상화
/// - Riverpod을 통한 의존성 주입
/// - Mock 데이터소스로 오프라인 개발 지원
library;

// Application Layer
export 'application/application.dart';
// Data Layer
export 'data/data.dart';
// Domain Layer
export 'domain/domain.dart';
// Presentation Layer
export 'presentation/presentation.dart';
