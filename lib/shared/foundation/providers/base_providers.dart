import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository Provider 생성 헬퍼
class RepositoryProviderHelper {
  RepositoryProviderHelper._();

  /// Repository Provider 생성
  static Provider<T> createRepository<T>(T Function() factory) {
    return Provider<T>((ref) => factory());
  }

  /// Repository Provider 생성 (파라미터 필요)
  static Provider<T> Function(P) createRepositoryWithParam<T, P>(
    T Function(P param) factory,
  ) {
    return (P param) => Provider<T>((ref) => factory(param));
  }
}

/// UseCase Provider 생성 헬퍼
class UseCaseProviderHelper {
  UseCaseProviderHelper._();

  /// UseCase Provider 생성 (Repository 의존)
  static Provider<T> createUseCase<T, R>(
    T Function(R repository) factory,
    Provider<R> repositoryProvider,
  ) {
    return Provider<T>((ref) {
      final repository = ref.read(repositoryProvider);
      return factory(repository);
    });
  }

  /// UseCase Provider 생성 (파라미터 필요)
  static Provider<T> Function(P) createUseCaseWithParam<T, P, R>(
    T Function(R repository, P param) factory,
    Provider<R> repositoryProvider,
  ) {
    return (P param) => Provider<T>((ref) {
      final repository = ref.read(repositoryProvider);
      return factory(repository, param);
    });
  }
}

/// Notifier Provider 생성 헬퍼
class NotifierProviderHelper {
  NotifierProviderHelper._();

  /// 기본 Notifier Provider 생성
  static NotifierProvider<T, S> createNotifier<T extends Notifier<S>, S>(
    T Function() factory,
  ) {
    return NotifierProvider<T, S>(factory);
  }

  /// Family Notifier Provider 생성
  static NotifierProvider<T, S> Function(P)
  createFamilyNotifier<T extends Notifier<S>, S, P>(T Function(P) factory) {
    return (P param) => NotifierProvider<T, S>(() => factory(param));
  }
}

/// 공통 Provider 패턴
class CommonProviders {
  CommonProviders._();

  /// CRUD Repository Provider 생성
  static Map<String, Provider> createCrudRepositoryProviders<T, ID>({
    required T Function() repositoryFactory,
    required String prefix,
  }) {
    return {'${prefix}Repository': Provider<T>((ref) => repositoryFactory())};
  }

  /// CRUD UseCase Provider 생성
  static Map<String, Provider> createCrudUseCaseProviders<T, R>({
    required Provider<R> repositoryProvider,
    required String prefix,
    required Map<String, T Function(R)> useCaseFactories,
  }) {
    final providers = <String, Provider>{};

    for (final entry in useCaseFactories.entries) {
      providers['$prefix${entry.key}'] = Provider<T>((ref) {
        final repository = ref.read(repositoryProvider);
        return entry.value(repository);
      });
    }

    return providers;
  }

  /// CRUD Notifier Provider 생성
  static Map<String, NotifierProvider> createCrudNotifierProviders<
    T extends Notifier<S>,
    S
  >({required String prefix, required T Function() notifierFactory}) {
    return {'${prefix}Notifier': NotifierProvider<T, S>(notifierFactory)};
  }
}

/// Provider 생성 빌더
class ProviderBuilder {
  ProviderBuilder._();

  /// Repository Provider 빌더
  static RepositoryProviderBuilder repository() => RepositoryProviderBuilder();

  /// UseCase Provider 빌더
  static UseCaseProviderBuilder useCase() => UseCaseProviderBuilder();

  /// Notifier Provider 빌더
  static NotifierProviderBuilder notifier() => NotifierProviderBuilder();
}

/// Repository Provider 빌더
class RepositoryProviderBuilder {
  /// 기본 Repository Provider 생성
  Provider<T> build<T>(T Function() factory) {
    return Provider<T>((ref) => factory());
  }

  /// 파라미터가 있는 Repository Provider 생성
  Provider<T> Function(P) buildWithParam<T, P>(T Function(P param) factory) {
    return (P param) => Provider<T>((ref) => factory(param));
  }
}

/// UseCase Provider 빌더
class UseCaseProviderBuilder {
  /// Repository 의존 UseCase Provider 생성
  Provider<T> build<T, R>(
    T Function(R repository) factory,
    Provider<R> repositoryProvider,
  ) {
    return Provider<T>((ref) {
      final repository = ref.read(repositoryProvider);
      return factory(repository);
    });
  }

  /// 파라미터가 있는 UseCase Provider 생성
  Provider<T> Function(P) buildWithParam<T, P, R>(
    T Function(R repository, P param) factory,
    Provider<R> repositoryProvider,
  ) {
    return (P param) => Provider<T>((ref) {
      final repository = ref.read(repositoryProvider);
      return factory(repository, param);
    });
  }
}

/// Notifier Provider 빌더
class NotifierProviderBuilder {
  /// 기본 Notifier Provider 생성
  NotifierProvider<T, S> build<T extends Notifier<S>, S>(T Function() factory) {
    return NotifierProvider<T, S>(factory);
  }

  /// Family Notifier Provider 생성
  NotifierProvider<T, S> Function(P) buildFamily<T extends Notifier<S>, S, P>(
    T Function(P) factory,
  ) {
    return (P param) => NotifierProvider<T, S>(() => factory(param));
  }
}
