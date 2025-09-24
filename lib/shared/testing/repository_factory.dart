import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'mock_config.dart';

/// 스마트 Repository Factory
///
/// 환경에 따라 Mock 또는 Real Repository 구현체를 자동으로 선택합니다.
/// 개발/테스트 환경에서는 Mock, 프로덕션에서는 Real API를 사용합니다.
class RepositoryFactory {
  static RepositoryFactory? _instance;

  RepositoryFactory._internal();

  factory RepositoryFactory() {
    _instance ??= RepositoryFactory._internal();
    return _instance!;
  }

  /// AI Repository 생성
  ///
  /// 환경에 따라 Mock 또는 Real 구현체 반환
  /// 현재는 의존성 주입 없이 팩토리 패턴만 시연
  AiRepository createAiRepository() {
    if (MockConfig.shouldUseMock) {
      // Mock 구현체 - 실제 구현 시 Mockito 객체 반환
      throw UnimplementedError(
        'Mock AI Repository는 의존성 주입이 필요합니다. '
        'Provider나 테스트에서 직접 생성하세요.',
      );
    } else {
      // Real 구현체 - 실제 구현 시 API 구현체 반환
      throw UnimplementedError(
        'Real AI Repository는 의존성 주입이 필요합니다. '
        'Provider에서 필요한 의존성과 함께 생성하세요.',
      );
    }
  }

  /// Auth Repository 생성
  ///
  /// 환경에 따라 Mock 또는 Real 구현체 반환
  /// 현재는 의존성 주입 없이 팩토리 패턴만 시연
  AuthRepository createAuthRepository() {
    if (MockConfig.shouldUseMock) {
      // Mock 구현체 - 실제 구현 시 Mockito 객체 반환
      throw UnimplementedError(
        'Mock Auth Repository는 의존성 주입이 필요합니다. '
        'Provider나 테스트에서 직접 생성하세요.',
      );
    } else {
      // Real 구현체 - 실제 구현 시 API 구현체 반환
      throw UnimplementedError(
        'Real Auth Repository는 의존성 주입이 필요합니다. '
        'Provider에서 필요한 의존성과 함께 생성하세요.',
      );
    }
  }

  /// Home Repository 생성
  ///
  /// 환경에 따라 Mock 또는 Real 구현체 반환
  /// 현재는 의존성 주입 없이 팩토리 패턴만 시연
  HomeRepository createHomeRepository() {
    if (MockConfig.shouldUseMock) {
      // Mock 구현체 - 실제 구현 시 Mockito 객체 반환
      throw UnimplementedError(
        'Mock Home Repository는 의존성 주입이 필요합니다. '
        'Provider나 테스트에서 직접 생성하세요.',
      );
    } else {
      // Real 구현체 - 실제 구현 시 API 구현체 반환
      throw UnimplementedError(
        'Real Home Repository는 의존성 주입이 필요합니다. '
        'Provider에서 필요한 의존성과 함께 생성하세요.',
      );
    }
  }

  /// Pet Repository 생성
  ///
  /// 환경에 따라 Mock 또는 Real 구현체 반환
  /// 현재는 의존성 주입 없이 팩토리 패턴만 시연
  PetRepository createPetRepository() {
    if (MockConfig.shouldUseMock) {
      // Mock 구현체 - 실제 구현 시 Mockito 객체 반환
      throw UnimplementedError(
        'Mock Pet Repository는 의존성 주입이 필요합니다. '
        'Provider나 테스트에서 직접 생성하세요.',
      );
    } else {
      // Real 구현체 - 실제 구현 시 API 구현체 반환
      throw UnimplementedError(
        'Real Pet Repository는 의존성 주입이 필요합니다. '
        'Provider에서 필요한 의존성과 함께 생성하세요.',
      );
    }
  }

  /// Factory 초기화 (테스트용)
  static void reset() {
    _instance = null;
  }

  /// 현재 사용 중인 모든 Repository 타입 확인
  Map<String, String> getRepositoryTypes() {
    final useMock = MockConfig.shouldUseMock;
    return {
      'environment': MockConfig.currentEnvironment.name,
      'useMock': useMock.toString(),
      'aiRepository': useMock ? 'Mock' : 'Real',
      'authRepository': useMock ? 'Mock' : 'Real',
      'homeRepository': useMock ? 'Mock' : 'Real',
      'petRepository': useMock ? 'Mock' : 'Real',
    };
  }
}

/// Repository Provider Extensions
///
/// Riverpod Provider에서 사용할 수 있는 편의 메서드들
extension RepositoryFactoryExtensions on RepositoryFactory {
  /// AI Repository Provider에서 사용
  T createRepository<T>() {
    if (T == AiRepository) {
      return createAiRepository() as T;
    } else if (T == AuthRepository) {
      return createAuthRepository() as T;
    } else if (T == HomeRepository) {
      return createHomeRepository() as T;
    } else if (T == PetRepository) {
      return createPetRepository() as T;
    } else {
      throw ArgumentError('지원하지 않는 Repository 타입입니다: $T');
    }
  }
}

/// Repository Factory Provider (Riverpod용)
///
/// 다른 Provider에서 Repository를 의존성 주입할 때 사용
class RepositoryFactoryProvider {
  static final _factory = RepositoryFactory();

  /// AI Repository Provider
  static AiRepository get aiRepository => _factory.createAiRepository();

  /// Auth Repository Provider
  static AuthRepository get authRepository => _factory.createAuthRepository();

  /// Home Repository Provider
  static HomeRepository get homeRepository => _factory.createHomeRepository();

  /// Pet Repository Provider
  static PetRepository get petRepository => _factory.createPetRepository();

  /// Repository 타입 디버그 정보
  static Map<String, String> get debugInfo => _factory.getRepositoryTypes();
}
