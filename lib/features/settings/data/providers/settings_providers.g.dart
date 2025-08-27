// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRepositoryHash() =>
    r'0b1a0f93fedc43c7d717da6b24185dae1f2054d1';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider =
    AutoDisposeProvider<SettingsRepositoryImpl>.internal(
      settingsRepository,
      name: r'settingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = AutoDisposeProviderRef<SettingsRepositoryImpl>;
String _$getUserProfileUseCaseHash() =>
    r'6dedc1625e31cea9e9510f349429fa6c77539710';

/// See also [getUserProfileUseCase].
@ProviderFor(getUserProfileUseCase)
final getUserProfileUseCaseProvider =
    AutoDisposeProvider<GetUserProfileUseCase>.internal(
      getUserProfileUseCase,
      name: r'getUserProfileUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getUserProfileUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetUserProfileUseCaseRef =
    AutoDisposeProviderRef<GetUserProfileUseCase>;
String _$updateUserProfileUseCaseHash() =>
    r'3c84af363f7332151887ee311768681a55bde884';

/// See also [updateUserProfileUseCase].
@ProviderFor(updateUserProfileUseCase)
final updateUserProfileUseCaseProvider =
    AutoDisposeProvider<UpdateUserProfileUseCase>.internal(
      updateUserProfileUseCase,
      name: r'updateUserProfileUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$updateUserProfileUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateUserProfileUseCaseRef =
    AutoDisposeProviderRef<UpdateUserProfileUseCase>;
String _$getAppSettingsUseCaseHash() =>
    r'd22ab0dcd328aa30e2e67a01ce8f1b9f06712963';

/// See also [getAppSettingsUseCase].
@ProviderFor(getAppSettingsUseCase)
final getAppSettingsUseCaseProvider =
    AutoDisposeProvider<GetAppSettingsUseCase>.internal(
      getAppSettingsUseCase,
      name: r'getAppSettingsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getAppSettingsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetAppSettingsUseCaseRef =
    AutoDisposeProviderRef<GetAppSettingsUseCase>;
String _$saveAppSettingsUseCaseHash() =>
    r'3e2e09c9e6d6e68f953a9d8a8ca8f350af07290d';

/// See also [saveAppSettingsUseCase].
@ProviderFor(saveAppSettingsUseCase)
final saveAppSettingsUseCaseProvider =
    AutoDisposeProvider<SaveAppSettingsUseCase>.internal(
      saveAppSettingsUseCase,
      name: r'saveAppSettingsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$saveAppSettingsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveAppSettingsUseCaseRef =
    AutoDisposeProviderRef<SaveAppSettingsUseCase>;
String _$userProfileNotifierHash() =>
    r'77d96d2a9fb29f6c7a25c9d99f5c05947b9a7ab6';

/// See also [UserProfileNotifier].
@ProviderFor(UserProfileNotifier)
final userProfileNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      UserProfileNotifier,
      UserProfileEntity
    >.internal(
      UserProfileNotifier.new,
      name: r'userProfileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userProfileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserProfileNotifier = AutoDisposeAsyncNotifier<UserProfileEntity>;
String _$appSettingsNotifierHash() =>
    r'1ad6f35fef39a68babb768c41e02e25adb830b9d';

/// See also [AppSettingsNotifier].
@ProviderFor(AppSettingsNotifier)
final appSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      AppSettingsNotifier,
      AppSettingsEntity
    >.internal(
      AppSettingsNotifier.new,
      name: r'appSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppSettingsNotifier = AutoDisposeAsyncNotifier<AppSettingsEntity>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
