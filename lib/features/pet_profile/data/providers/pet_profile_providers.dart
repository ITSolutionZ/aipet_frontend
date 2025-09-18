import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/pet_profile_repository.dart';
import '../../domain/services/pet_profile_domain_service.dart';
import '../../domain/usecases/get_pet_profile_usecase.dart';
import '../../domain/usecases/manage_family_managers_usecase.dart';
import '../../domain/usecases/update_pet_profile_usecase.dart';
import '../repositories/pet_profile_repository_impl.dart';

/// Pet Profile Data Layer Providers
///
/// Pet Profile 기능의 Data Layer 의존성 주입을 담당

// Repository Provider
final petProfileRepositoryProvider = Provider<PetProfileRepository>((ref) {
  return PetProfileRepositoryImpl();
});

// Domain Service Provider
final petProfileDomainServiceProvider = Provider<PetProfileDomainService>((ref) {
  return PetProfileDomainServiceImpl();
});

// UseCase Providers
final getPetProfileUseCaseProvider = Provider<GetPetProfileUseCase>((ref) {
  return GetPetProfileUseCase(
    ref.read(petProfileRepositoryProvider),
  );
});

final updatePetProfileUseCaseProvider = Provider<UpdatePetProfileUseCase>((ref) {
  return UpdatePetProfileUseCase(
    ref.read(petProfileRepositoryProvider),
    ref.read(petProfileDomainServiceProvider),
  );
});

final manageFamilyManagersUseCaseProvider = Provider<ManageFamilyManagersUseCase>((ref) {
  return ManageFamilyManagersUseCase(
    ref.read(petProfileRepositoryProvider),
    ref.read(petProfileDomainServiceProvider),
  );
});