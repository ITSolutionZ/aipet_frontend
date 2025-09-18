// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petProfileNotifierHash() =>
    r'cc28840768e29e8c2c936c69f9c26ff4b04bb0d7';

/// 펫 프로필 컨트롤러 (Clean Architecture 적용)
///
/// Copied from [PetProfileNotifier].
@ProviderFor(PetProfileNotifier)
final petProfileNotifierProvider =
    AutoDisposeNotifierProvider<PetProfileNotifier, PetProfileState>.internal(
      PetProfileNotifier.new,
      name: r'petProfileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$petProfileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PetProfileNotifier = AutoDisposeNotifier<PetProfileState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
