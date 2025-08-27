// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_share_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walkShareRepositoryHash() =>
    r'efdcda7778f22e7c32618b8445397a6fb9234544';

/// WalkShareRepository 프로바이더
///
/// Copied from [walkShareRepository].
@ProviderFor(walkShareRepository)
final walkShareRepositoryProvider =
    AutoDisposeProvider<WalkShareRepository>.internal(
      walkShareRepository,
      name: r'walkShareRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$walkShareRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalkShareRepositoryRef = AutoDisposeProviderRef<WalkShareRepository>;
String _$copyToClipboardUseCaseHash() =>
    r'e8b280e15e5c756ffa1800c0a26b01eb654311eb';

/// CopyToClipboardUseCase 프로바이더
///
/// Copied from [copyToClipboardUseCase].
@ProviderFor(copyToClipboardUseCase)
final copyToClipboardUseCaseProvider =
    AutoDisposeProvider<CopyToClipboardUseCase>.internal(
      copyToClipboardUseCase,
      name: r'copyToClipboardUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$copyToClipboardUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CopyToClipboardUseCaseRef =
    AutoDisposeProviderRef<CopyToClipboardUseCase>;
String _$saveAsImageUseCaseHash() =>
    r'c368be0d27b643412a5056a102cfff8f5882b872';

/// SaveAsImageUseCase 프로바이더
///
/// Copied from [saveAsImageUseCase].
@ProviderFor(saveAsImageUseCase)
final saveAsImageUseCaseProvider =
    AutoDisposeProvider<SaveAsImageUseCase>.internal(
      saveAsImageUseCase,
      name: r'saveAsImageUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$saveAsImageUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveAsImageUseCaseRef = AutoDisposeProviderRef<SaveAsImageUseCase>;
String _$systemShareUseCaseHash() =>
    r'942246126102f77748df296b8db934373e67c3e9';

/// SystemShareUseCase 프로바이더
///
/// Copied from [systemShareUseCase].
@ProviderFor(systemShareUseCase)
final systemShareUseCaseProvider =
    AutoDisposeProvider<SystemShareUseCase>.internal(
      systemShareUseCase,
      name: r'systemShareUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$systemShareUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SystemShareUseCaseRef = AutoDisposeProviderRef<SystemShareUseCase>;
String _$generateShareTextUseCaseHash() =>
    r'6b7aad80cd6872e52e7fbcffc92b0cb1c0b31503';

/// GenerateShareTextUseCase 프로바이더
///
/// Copied from [generateShareTextUseCase].
@ProviderFor(generateShareTextUseCase)
final generateShareTextUseCaseProvider =
    AutoDisposeProvider<GenerateShareTextUseCase>.internal(
      generateShareTextUseCase,
      name: r'generateShareTextUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$generateShareTextUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GenerateShareTextUseCaseRef =
    AutoDisposeProviderRef<GenerateShareTextUseCase>;
String _$shareTextHash() => r'9adb4c8846e7c6ebd87eba4189dc13de65bf2808';

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

/// 공유 텍스트 프로바이더
///
/// Copied from [shareText].
@ProviderFor(shareText)
const shareTextProvider = ShareTextFamily();

/// 공유 텍스트 프로바이더
///
/// Copied from [shareText].
class ShareTextFamily extends Family<String> {
  /// 공유 텍스트 프로바이더
  ///
  /// Copied from [shareText].
  const ShareTextFamily();

  /// 공유 텍스트 프로바이더
  ///
  /// Copied from [shareText].
  ShareTextProvider call(WalkRecordEntity walkRecord) {
    return ShareTextProvider(walkRecord);
  }

  @override
  ShareTextProvider getProviderOverride(covariant ShareTextProvider provider) {
    return call(provider.walkRecord);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shareTextProvider';
}

/// 공유 텍스트 프로바이더
///
/// Copied from [shareText].
class ShareTextProvider extends AutoDisposeProvider<String> {
  /// 공유 텍스트 프로바이더
  ///
  /// Copied from [shareText].
  ShareTextProvider(WalkRecordEntity walkRecord)
    : this._internal(
        (ref) => shareText(ref as ShareTextRef, walkRecord),
        from: shareTextProvider,
        name: r'shareTextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shareTextHash,
        dependencies: ShareTextFamily._dependencies,
        allTransitiveDependencies: ShareTextFamily._allTransitiveDependencies,
        walkRecord: walkRecord,
      );

  ShareTextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.walkRecord,
  }) : super.internal();

  final WalkRecordEntity walkRecord;

  @override
  Override overrideWith(String Function(ShareTextRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: ShareTextProvider._internal(
        (ref) => create(ref as ShareTextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        walkRecord: walkRecord,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _ShareTextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShareTextProvider && other.walkRecord == walkRecord;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, walkRecord.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShareTextRef on AutoDisposeProviderRef<String> {
  /// The parameter `walkRecord` of this provider.
  WalkRecordEntity get walkRecord;
}

class _ShareTextProviderElement extends AutoDisposeProviderElement<String>
    with ShareTextRef {
  _ShareTextProviderElement(super.provider);

  @override
  WalkRecordEntity get walkRecord => (origin as ShareTextProvider).walkRecord;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
