// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingRepositoryHash() =>
    r'73985613e633a57080d991f055104ce2e16cfa06';

/// See also [onboardingRepository].
@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider =
    AutoDisposeProvider<OnboardingRepository>.internal(
      onboardingRepository,
      name: r'onboardingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingRepositoryRef = AutoDisposeProviderRef<OnboardingRepository>;
String _$onboardingStateNotifierHash() =>
    r'eabe55dfde997cf70a07e82e079e9d3dae75f92b';

/// See also [OnboardingStateNotifier].
@ProviderFor(OnboardingStateNotifier)
final onboardingStateNotifierProvider =
    AutoDisposeNotifierProvider<
      OnboardingStateNotifier,
      OnboardingState
    >.internal(
      OnboardingStateNotifier.new,
      name: r'onboardingStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingStateNotifier = AutoDisposeNotifier<OnboardingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
