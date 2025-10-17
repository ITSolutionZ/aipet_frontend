// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 펫 프로필 컨트롤러 (Clean Architecture 적용)

@ProviderFor(PetProfileNotifier)
const petProfileProvider = PetProfileNotifierProvider._();

/// 펫 프로필 컨트롤러 (Clean Architecture 적용)
final class PetProfileNotifierProvider
    extends $NotifierProvider<PetProfileNotifier, PetProfileState> {
  /// 펫 프로필 컨트롤러 (Clean Architecture 적용)
  const PetProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'petProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$petProfileNotifierHash();

  @$internal
  @override
  PetProfileNotifier create() => PetProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PetProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PetProfileState>(value),
    );
  }
}

String _$petProfileNotifierHash() =>
    r'feffe2825afef23ef9e501aae804e26cc7ce2bd9';

/// 펫 프로필 컨트롤러 (Clean Architecture 적용)

abstract class _$PetProfileNotifier extends $Notifier<PetProfileState> {
  PetProfileState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PetProfileState, PetProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PetProfileState, PetProfileState>,
              PetProfileState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
