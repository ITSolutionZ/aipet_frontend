// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeCurrentTimeStreamHash() =>
    r'4760699ad6924eaca2894ccf8726040b5f64dd6f';

/// See also [homeCurrentTimeStream].
@ProviderFor(homeCurrentTimeStream)
final homeCurrentTimeStreamProvider =
    AutoDisposeStreamProvider<String>.internal(
      homeCurrentTimeStream,
      name: r'homeCurrentTimeStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeCurrentTimeStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeCurrentTimeStreamRef = AutoDisposeStreamProviderRef<String>;
String _$homeStateHash() => r'0cd9d847323020f6ae3dd2a2003943b1cf5afb34';

/// See also [HomeState].
@ProviderFor(HomeState)
final homeStateProvider =
    AutoDisposeNotifierProvider<HomeState, HomeStateData>.internal(
      HomeState.new,
      name: r'homeStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeState = AutoDisposeNotifier<HomeStateData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
