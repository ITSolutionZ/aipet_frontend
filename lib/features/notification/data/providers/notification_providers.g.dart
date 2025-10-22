// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRepository)
const notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepositoryImpl,
          NotificationRepositoryImpl,
          NotificationRepositoryImpl
        >
    with $Provider<NotificationRepositoryImpl> {
  const NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepositoryImpl create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepositoryImpl>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'b1b68c99378a50cdc78044b490f38283b29a4e66';

@ProviderFor(NotificationsNotifier)
const notificationsProvider = NotificationsNotifierProvider._();

final class NotificationsNotifierProvider
    extends
        $AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>> {
  const NotificationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsNotifierHash();

  @$internal
  @override
  NotificationsNotifier create() => NotificationsNotifier();
}

String _$notificationsNotifierHash() =>
    r'c6376dec8026de077b2db0ea9d62ebb585074cbf';

abstract class _$NotificationsNotifier
    extends $AsyncNotifier<List<NotificationModel>> {
  FutureOr<List<NotificationModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<NotificationModel>>,
              List<NotificationModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NotificationModel>>,
                List<NotificationModel>
              >,
              AsyncValue<List<NotificationModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(notificationById)
const notificationByIdProvider = NotificationByIdFamily._();

final class NotificationByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationModel?>,
          NotificationModel?,
          FutureOr<NotificationModel?>
        >
    with
        $FutureModifier<NotificationModel?>,
        $FutureProvider<NotificationModel?> {
  const NotificationByIdProvider._({
    required NotificationByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'notificationByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationByIdHash();

  @override
  String toString() {
    return r'notificationByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NotificationModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationModel?> create(Ref ref) {
    final argument = this.argument as String;
    return notificationById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationByIdHash() => r'b155bb39b7170ab418b07edf5d273fa995e1fe03';

final class NotificationByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NotificationModel?>, String> {
  const NotificationByIdFamily._()
    : super(
        retry: null,
        name: r'notificationByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotificationByIdProvider call(String id) =>
      NotificationByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'notificationByIdProvider';
}

@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountProvider._();

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const UnreadNotificationCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadNotificationCount(ref);
  }
}

String _$unreadNotificationCountHash() =>
    r'cb7dbb2ba3f7700cf56a4081aad87a794c340aba';

@ProviderFor(NotificationSettingsNotifier)
const notificationSettingsProvider = NotificationSettingsNotifierProvider._();

final class NotificationSettingsNotifierProvider
    extends
        $AsyncNotifierProvider<
          NotificationSettingsNotifier,
          Map<String, dynamic>
        > {
  const NotificationSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsNotifierHash();

  @$internal
  @override
  NotificationSettingsNotifier create() => NotificationSettingsNotifier();
}

String _$notificationSettingsNotifierHash() =>
    r'3a711f4a80bd1b221b2aa369a086fa1e7a061aea';

abstract class _$NotificationSettingsNotifier
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
