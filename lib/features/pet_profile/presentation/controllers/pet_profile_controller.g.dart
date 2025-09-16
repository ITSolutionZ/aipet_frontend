// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petProfileNotifierHash() =>
    r'2c4f72e7983a014bb2c67049f17a3aeda52006e0';

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
