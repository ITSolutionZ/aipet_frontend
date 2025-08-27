// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationRepositoryHash() =>
    r'b1b68c99378a50cdc78044b490f38283b29a4e66';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepositoryImpl>.internal(
      notificationRepository,
      name: r'notificationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRepositoryRef =
    AutoDisposeProviderRef<NotificationRepositoryImpl>;
String _$getNotificationsUseCaseHash() =>
    r'b65eef3e175ea70d4f18d0f31cc16d4764abba9b';

/// See also [getNotificationsUseCase].
@ProviderFor(getNotificationsUseCase)
final getNotificationsUseCaseProvider =
    AutoDisposeProvider<GetNotificationsUseCase>.internal(
      getNotificationsUseCase,
      name: r'getNotificationsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getNotificationsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetNotificationsUseCaseRef =
    AutoDisposeProviderRef<GetNotificationsUseCase>;
String _$getNotificationByIdUseCaseHash() =>
    r'cd5d704d140f627bbece6b6e92cf5d828e8cd6e7';

/// See also [getNotificationByIdUseCase].
@ProviderFor(getNotificationByIdUseCase)
final getNotificationByIdUseCaseProvider =
    AutoDisposeProvider<GetNotificationByIdUseCase>.internal(
      getNotificationByIdUseCase,
      name: r'getNotificationByIdUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getNotificationByIdUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetNotificationByIdUseCaseRef =
    AutoDisposeProviderRef<GetNotificationByIdUseCase>;
String _$markNotificationAsReadUseCaseHash() =>
    r'396840422471720054bf6ae03eae2a1de998d131';

/// See also [markNotificationAsReadUseCase].
@ProviderFor(markNotificationAsReadUseCase)
final markNotificationAsReadUseCaseProvider =
    AutoDisposeProvider<MarkNotificationAsReadUseCase>.internal(
      markNotificationAsReadUseCase,
      name: r'markNotificationAsReadUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$markNotificationAsReadUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MarkNotificationAsReadUseCaseRef =
    AutoDisposeProviderRef<MarkNotificationAsReadUseCase>;
String _$deleteNotificationUseCaseHash() =>
    r'476cb2747d3222508e06f944d299e1fd3a85a006';

/// See also [deleteNotificationUseCase].
@ProviderFor(deleteNotificationUseCase)
final deleteNotificationUseCaseProvider =
    AutoDisposeProvider<DeleteNotificationUseCase>.internal(
      deleteNotificationUseCase,
      name: r'deleteNotificationUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteNotificationUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteNotificationUseCaseRef =
    AutoDisposeProviderRef<DeleteNotificationUseCase>;
String _$notificationByIdHash() => r'4cc400fa9f22064a78ddf61e188d79501a7d6237';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [notificationById].
@ProviderFor(notificationById)
const notificationByIdProvider = NotificationByIdFamily();

/// See also [notificationById].
class NotificationByIdFamily extends Family<AsyncValue<NotificationModel?>> {
  /// See also [notificationById].
  const NotificationByIdFamily();

  /// See also [notificationById].
  NotificationByIdProvider call(String id) {
    return NotificationByIdProvider(id);
  }

  @override
  NotificationByIdProvider getProviderOverride(
    covariant NotificationByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notificationByIdProvider';
}

/// See also [notificationById].
class NotificationByIdProvider
    extends AutoDisposeFutureProvider<NotificationModel?> {
  /// See also [notificationById].
  NotificationByIdProvider(String id)
    : this._internal(
        (ref) => notificationById(ref as NotificationByIdRef, id),
        from: notificationByIdProvider,
        name: r'notificationByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$notificationByIdHash,
        dependencies: NotificationByIdFamily._dependencies,
        allTransitiveDependencies:
            NotificationByIdFamily._allTransitiveDependencies,
        id: id,
      );

  NotificationByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<NotificationModel?> Function(NotificationByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotificationByIdProvider._internal(
        (ref) => create(ref as NotificationByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<NotificationModel?> createElement() {
    return _NotificationByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotificationByIdRef on AutoDisposeFutureProviderRef<NotificationModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _NotificationByIdProviderElement
    extends AutoDisposeFutureProviderElement<NotificationModel?>
    with NotificationByIdRef {
  _NotificationByIdProviderElement(super.provider);

  @override
  String get id => (origin as NotificationByIdProvider).id;
}

String _$unreadNotificationCountHash() =>
    r'490b1dd3862c47d10e69f68a9c5ebaa455e88fc5';

/// See also [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = AutoDisposeFutureProvider<int>.internal(
  unreadNotificationCount,
  name: r'unreadNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationCountRef = AutoDisposeFutureProviderRef<int>;
String _$notificationsNotifierHash() =>
    r'2d7cb162ce48b0ac5cede90b95b41a7907459da1';

/// See also [NotificationsNotifier].
@ProviderFor(NotificationsNotifier)
final notificationsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationsNotifier,
      List<NotificationModel>
    >.internal(
      NotificationsNotifier.new,
      name: r'notificationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationsNotifier =
    AutoDisposeAsyncNotifier<List<NotificationModel>>;
String _$notificationSettingsNotifierHash() =>
    r'3986e8aeef49d80ed0d12044a7d86e025e10a333';

/// See also [NotificationSettingsNotifier].
@ProviderFor(NotificationSettingsNotifier)
final notificationSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationSettingsNotifier,
      NotificationSettings
    >.internal(
      NotificationSettingsNotifier.new,
      name: r'notificationSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationSettingsNotifier =
    AutoDisposeAsyncNotifier<NotificationSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
