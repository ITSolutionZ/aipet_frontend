// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
const settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepositoryImpl,
          SettingsRepositoryImpl,
          SettingsRepositoryImpl
        >
    with $Provider<SettingsRepositoryImpl> {
  const SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepositoryImpl create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepositoryImpl>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'0b1a0f93fedc43c7d717da6b24185dae1f2054d1';

@ProviderFor(getUserProfileUseCase)
const getUserProfileUseCaseProvider = GetUserProfileUseCaseProvider._();

final class GetUserProfileUseCaseProvider
    extends
        $FunctionalProvider<
          GetUserProfileUseCase,
          GetUserProfileUseCase,
          GetUserProfileUseCase
        >
    with $Provider<GetUserProfileUseCase> {
  const GetUserProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getUserProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getUserProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetUserProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetUserProfileUseCase create(Ref ref) {
    return getUserProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetUserProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetUserProfileUseCase>(value),
    );
  }
}

String _$getUserProfileUseCaseHash() =>
    r'6dedc1625e31cea9e9510f349429fa6c77539710';

@ProviderFor(updateUserProfileUseCase)
const updateUserProfileUseCaseProvider = UpdateUserProfileUseCaseProvider._();

final class UpdateUserProfileUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateUserProfileUseCase,
          UpdateUserProfileUseCase,
          UpdateUserProfileUseCase
        >
    with $Provider<UpdateUserProfileUseCase> {
  const UpdateUserProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateUserProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateUserProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateUserProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateUserProfileUseCase create(Ref ref) {
    return updateUserProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateUserProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateUserProfileUseCase>(value),
    );
  }
}

String _$updateUserProfileUseCaseHash() =>
    r'3c84af363f7332151887ee311768681a55bde884';

@ProviderFor(getAppSettingsUseCase)
const getAppSettingsUseCaseProvider = GetAppSettingsUseCaseProvider._();

final class GetAppSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          GetAppSettingsUseCase,
          GetAppSettingsUseCase,
          GetAppSettingsUseCase
        >
    with $Provider<GetAppSettingsUseCase> {
  const GetAppSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAppSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAppSettingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetAppSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetAppSettingsUseCase create(Ref ref) {
    return getAppSettingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetAppSettingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetAppSettingsUseCase>(value),
    );
  }
}

String _$getAppSettingsUseCaseHash() =>
    r'd22ab0dcd328aa30e2e67a01ce8f1b9f06712963';

@ProviderFor(saveAppSettingsUseCase)
const saveAppSettingsUseCaseProvider = SaveAppSettingsUseCaseProvider._();

final class SaveAppSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          SaveAppSettingsUseCase,
          SaveAppSettingsUseCase,
          SaveAppSettingsUseCase
        >
    with $Provider<SaveAppSettingsUseCase> {
  const SaveAppSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveAppSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveAppSettingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveAppSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveAppSettingsUseCase create(Ref ref) {
    return saveAppSettingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveAppSettingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveAppSettingsUseCase>(value),
    );
  }
}

String _$saveAppSettingsUseCaseHash() =>
    r'3e2e09c9e6d6e68f953a9d8a8ca8f350af07290d';

@ProviderFor(changePasswordUseCase)
const changePasswordUseCaseProvider = ChangePasswordUseCaseProvider._();

final class ChangePasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ChangePasswordUseCase,
          ChangePasswordUseCase,
          ChangePasswordUseCase
        >
    with $Provider<ChangePasswordUseCase> {
  const ChangePasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ChangePasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangePasswordUseCase create(Ref ref) {
    return changePasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordUseCase>(value),
    );
  }
}

String _$changePasswordUseCaseHash() =>
    r'ac036b380d5bb158fe063811c3927ff5a9cb863c';

@ProviderFor(deleteAccountUseCase)
const deleteAccountUseCaseProvider = DeleteAccountUseCaseProvider._();

final class DeleteAccountUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteAccountUseCase,
          DeleteAccountUseCase,
          DeleteAccountUseCase
        >
    with $Provider<DeleteAccountUseCase> {
  const DeleteAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteAccountUseCase create(Ref ref) {
    return deleteAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccountUseCase>(value),
    );
  }
}

String _$deleteAccountUseCaseHash() =>
    r'f6d11a294e74f96d009e17b7ad966e1d1cf5c239';

@ProviderFor(exportAppDataUseCase)
const exportAppDataUseCaseProvider = ExportAppDataUseCaseProvider._();

final class ExportAppDataUseCaseProvider
    extends
        $FunctionalProvider<
          ExportAppDataUseCase,
          ExportAppDataUseCase,
          ExportAppDataUseCase
        >
    with $Provider<ExportAppDataUseCase> {
  const ExportAppDataUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportAppDataUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportAppDataUseCaseHash();

  @$internal
  @override
  $ProviderElement<ExportAppDataUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExportAppDataUseCase create(Ref ref) {
    return exportAppDataUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportAppDataUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportAppDataUseCase>(value),
    );
  }
}

String _$exportAppDataUseCaseHash() =>
    r'6039efec066c24cc510b8d28ebb7ac0fd1551fc5';

@ProviderFor(importAppDataUseCase)
const importAppDataUseCaseProvider = ImportAppDataUseCaseProvider._();

final class ImportAppDataUseCaseProvider
    extends
        $FunctionalProvider<
          ImportAppDataUseCase,
          ImportAppDataUseCase,
          ImportAppDataUseCase
        >
    with $Provider<ImportAppDataUseCase> {
  const ImportAppDataUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importAppDataUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importAppDataUseCaseHash();

  @$internal
  @override
  $ProviderElement<ImportAppDataUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImportAppDataUseCase create(Ref ref) {
    return importAppDataUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportAppDataUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportAppDataUseCase>(value),
    );
  }
}

String _$importAppDataUseCaseHash() =>
    r'ccbc0b3e557698b0fa933505943332c7b9dfdd4e';

@ProviderFor(clearAppCacheUseCase)
const clearAppCacheUseCaseProvider = ClearAppCacheUseCaseProvider._();

final class ClearAppCacheUseCaseProvider
    extends
        $FunctionalProvider<
          ClearAppCacheUseCase,
          ClearAppCacheUseCase,
          ClearAppCacheUseCase
        >
    with $Provider<ClearAppCacheUseCase> {
  const ClearAppCacheUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearAppCacheUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearAppCacheUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearAppCacheUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearAppCacheUseCase create(Ref ref) {
    return clearAppCacheUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearAppCacheUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearAppCacheUseCase>(value),
    );
  }
}

String _$clearAppCacheUseCaseHash() =>
    r'bcab7fdfe870c5ec28dce0b407486bb4d7c88ce8';

@ProviderFor(UserProfileNotifier)
const userProfileProvider = UserProfileNotifierProvider._();

final class UserProfileNotifierProvider
    extends $AsyncNotifierProvider<UserProfileNotifier, Map<String, dynamic>> {
  const UserProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileNotifierHash();

  @$internal
  @override
  UserProfileNotifier create() => UserProfileNotifier();
}

String _$userProfileNotifierHash() =>
    r'60cf08ac9bad8b9ec97de65eb297f59126ee53f9';

abstract class _$UserProfileNotifier
    extends $AsyncNotifier<Map<String, dynamic>> {
  FutureOr<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, dynamic>>,
                Map<String, dynamic>
              >,
              AsyncValue<Map<String, dynamic>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(AppSettingsNotifier)
const appSettingsProvider = AppSettingsNotifierProvider._();

final class AppSettingsNotifierProvider
    extends $AsyncNotifierProvider<AppSettingsNotifier, Map<String, dynamic>> {
  const AppSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsNotifierHash();

  @$internal
  @override
  AppSettingsNotifier create() => AppSettingsNotifier();
}

String _$appSettingsNotifierHash() =>
    r'bfa26820abe310cf50e52dd472d4b7da549aaab0';

abstract class _$AppSettingsNotifier
    extends $AsyncNotifier<Map<String, dynamic>> {
  FutureOr<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, dynamic>>,
                Map<String, dynamic>
              >,
              AsyncValue<Map<String, dynamic>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(settingsController)
const settingsControllerProvider = SettingsControllerProvider._();

final class SettingsControllerProvider
    extends
        $FunctionalProvider<
          SettingsController,
          SettingsController,
          SettingsController
        >
    with $Provider<SettingsController> {
  const SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  $ProviderElement<SettingsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsController create(Ref ref) {
    return settingsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsController>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'9e64ba4bab60d6502f546123f6a3af99038e3eff';
