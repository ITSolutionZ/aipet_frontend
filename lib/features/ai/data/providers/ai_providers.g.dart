// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiRepositoryHash() => r'd4c5069ca9910dffd8a411be374bc3fd93fb6036';

/// AI Repository Provider
///
/// 환경에 따라 Mock/Real Repository를 자동으로 전환합니다.
/// MockConfig.shouldUseMock 값에 따라 결정됩니다.
///
/// Copied from [aiRepository].
@ProviderFor(aiRepository)
final aiRepositoryProvider = AutoDisposeProvider<AiRepository>.internal(
  aiRepository,
  name: r'aiRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiRepositoryRef = AutoDisposeProviderRef<AiRepository>;
String _$legacyAiRepositoryHash() =>
    r'11056a4821d018f421422c2f58a5a21ee064ab8f';

/// Legacy AI Repository Provider (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지
///
/// Copied from [legacyAiRepository].
@ProviderFor(legacyAiRepository)
final legacyAiRepositoryProvider = AutoDisposeProvider<AiRepository>.internal(
  legacyAiRepository,
  name: r'legacyAiRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$legacyAiRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LegacyAiRepositoryRef = AutoDisposeProviderRef<AiRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
