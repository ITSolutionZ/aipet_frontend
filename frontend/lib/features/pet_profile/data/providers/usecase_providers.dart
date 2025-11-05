import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import '../../../../../features/pet_profile/domain/usecases/create_pet_usecase.dart';
import '../../../../../features/pet_profile/domain/usecases/delete_pet_usecase.dart';
import '../../../../../features/pet_profile/domain/usecases/get_all_pets_usecase.dart';
import '../../../../../features/pet_profile/domain/usecases/get_pet_profile_usecase.dart';
import '../../../../../features/pet_profile/domain/usecases/manage_family_managers_usecase.dart';
import '../../../../../features/pet_profile/domain/usecases/update_pet_profile_usecase.dart';
import '../../../../../features/pet_profile/domain/usecases/update_pet_usecase.dart';

part 'usecase_providers.g.dart';

/// UseCase 프로바이더들
@riverpod
GetAllPetsUseCase getAllPetsUseCase(Ref ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return GetAllPetsUseCase(repository);
}

@riverpod
GetPetProfileUseCase getPetProfileUseCase(Ref ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return GetPetProfileUseCase(repository);
}

@riverpod
CreatePetUseCase createPetUseCase(Ref ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return CreatePetUseCase(repository);
}

@riverpod
UpdatePetUseCase updatePetUseCase(Ref ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return UpdatePetUseCase(repository);
}

@riverpod
UpdatePetProfileUseCase updatePetProfileUseCase(Ref ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return UpdatePetProfileUseCase(repository);
}

@riverpod
DeletePetUseCase deletePetUseCase(Ref ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return DeletePetUseCase(repository);
}

@riverpod
ManageFamilyManagersUseCase manageFamilyManagersUseCase(Ref ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return ManageFamilyManagersUseCase(repository);
}
