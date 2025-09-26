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
String _$notificationByIdHash() => r'94fc19802148e34144efa20a2facf4099e62a6d7';

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
    r'1b7342c5955756ea13e347a0003d50e1e289c554';

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
    r'8ea79bf85456b5bd65e4c763236fcb0d83e84276';

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
    r'857be3d10af1adf8868df9e12ec1a98e51182e7c';

/// See also [NotificationSettingsNotifier].
@ProviderFor(NotificationSettingsNotifier)
final notificationSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationSettingsNotifier,
      Map<String, dynamic>
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
    AutoDisposeAsyncNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
