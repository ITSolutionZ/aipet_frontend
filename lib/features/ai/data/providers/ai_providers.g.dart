// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AI Repository Provider
///
/// AI 관련 추천, 즐겨찾기, 분석 기능을 담당합니다.

@ProviderFor(aiRepository)
const aiRepositoryProvider = AiRepositoryProvider._();

/// AI Repository Provider
///
/// AI 관련 추천, 즐겨찾기, 분석 기능을 담당합니다.

final class AiRepositoryProvider
    extends $FunctionalProvider<AiRepository, AiRepository, AiRepository>
    with $Provider<AiRepository> {
  /// AI Repository Provider
  ///
  /// AI 관련 추천, 즐겨찾기, 분석 기능을 담당합니다.
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

String _$aiRepositoryHash() => r'4379a2d7dfa462183b8403f8017504135a060097';

/// AI Chat Repository Provider
///
/// AI 채팅 관련 기능을 담당합니다 (메시지, 세션, 히스토리, 요약).

@ProviderFor(aiChatRepository)
const aiChatRepositoryProvider = AiChatRepositoryProvider._();

/// AI Chat Repository Provider
///
/// AI 채팅 관련 기능을 담당합니다 (메시지, 세션, 히스토리, 요약).

final class AiChatRepositoryProvider
    extends
        $FunctionalProvider<
          AiChatRepository,
          AiChatRepository,
          AiChatRepository
        >
    with $Provider<AiChatRepository> {
  /// AI Chat Repository Provider
  ///
  /// AI 채팅 관련 기능을 담당합니다 (메시지, 세션, 히스토리, 요약).
  const AiChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiChatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiChatRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AiChatRepository create(Ref ref) {
    return aiChatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiChatRepository>(value),
    );
  }
}

String _$aiChatRepositoryHash() => r'ad2eb2a62ca25c9ee0957f88d891c753a28aaf8d';

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
    r'1ecc5537430c458d8e59e60428b2d3ff707d9b25';
