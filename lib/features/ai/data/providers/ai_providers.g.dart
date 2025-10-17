// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AI Repository Provider
///
/// 환경에 따라 Mock/Real Repository를 자동으로 전환합니다.
/// MockConfig.shouldUseMock 값에 따라 결정됩니다.

@ProviderFor(aiRepository)
const aiRepositoryProvider = AiRepositoryProvider._();

/// AI Repository Provider
///
/// 환경에 따라 Mock/Real Repository를 자동으로 전환합니다.
/// MockConfig.shouldUseMock 값에 따라 결정됩니다.

final class AiRepositoryProvider
    extends $FunctionalProvider<AiRepository, AiRepository, AiRepository>
    with $Provider<AiRepository> {
  /// AI Repository Provider
  ///
  /// 환경에 따라 Mock/Real Repository를 자동으로 전환합니다.
  /// MockConfig.shouldUseMock 값에 따라 결정됩니다.
  const AiRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiRepository create(Ref ref) {
    return aiRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiRepository>(value),
    );
  }
}

String _$aiRepositoryHash() => r'd4c5069ca9910dffd8a411be374bc3fd93fb6036';

/// Legacy AI Repository Provider (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지

@ProviderFor(legacyAiRepository)
const legacyAiRepositoryProvider = LegacyAiRepositoryProvider._();

/// Legacy AI Repository Provider (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지

final class LegacyAiRepositoryProvider
    extends $FunctionalProvider<AiRepository, AiRepository, AiRepository>
    with $Provider<AiRepository> {
  /// Legacy AI Repository Provider (기존 구현체)
  ///
  /// 필요시 기존 구현체로 되돌릴 수 있도록 유지
  const LegacyAiRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legacyAiRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legacyAiRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiRepository create(Ref ref) {
    return legacyAiRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiRepository>(value),
    );
  }
}

String _$legacyAiRepositoryHash() =>
    r'11056a4821d018f421422c2f58a5a21ee064ab8f';
