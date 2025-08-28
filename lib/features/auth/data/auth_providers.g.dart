// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'364aac3bb9ea43f11efcaa8108aaed93f291e0b8';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
      sharedPreferences,
      name: r'sharedPreferencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharedPreferencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$navigationCallbackNotifierHash() =>
    r'fe943fb597bc00e8baf5b3fb3f40c26a125758f0';

/// See also [NavigationCallbackNotifier].
@ProviderFor(NavigationCallbackNotifier)
final navigationCallbackNotifierProvider =
    AutoDisposeNotifierProvider<
      NavigationCallbackNotifier,
      Function()?
    >.internal(
      NavigationCallbackNotifier.new,
      name: r'navigationCallbackNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$navigationCallbackNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NavigationCallbackNotifier = AutoDisposeNotifier<Function()?>;
String _$authFormStateNotifierHash() =>
    r'a15018124b3f92a3af108534d44b5f262089dbe4';

/// See also [AuthFormStateNotifier].
@ProviderFor(AuthFormStateNotifier)
final authFormStateNotifierProvider =
    AutoDisposeNotifierProvider<AuthFormStateNotifier, AuthFormState>.internal(
      AuthFormStateNotifier.new,
      name: r'authFormStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authFormStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthFormStateNotifier = AutoDisposeNotifier<AuthFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
