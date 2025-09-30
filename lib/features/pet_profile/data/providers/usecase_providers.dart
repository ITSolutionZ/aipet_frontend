import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/create_pet_usecase.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/delete_pet_usecase.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/get_all_pets_usecase.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/get_pet_profile_usecase.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/manage_family_managers_usecase.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/update_pet_profile_usecase.dart';
import 'package:aipet_frontend/features/pet_profile/domain/usecases/update_pet_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UseCase 프로바이더들
final getAllPetsUseCaseProvider = Provider<GetAllPetsUseCase>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return GetAllPetsUseCase(repository);
});

final getPetProfileUseCaseProvider = Provider<GetPetProfileUseCase>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return GetPetProfileUseCase(repository);
});

final createPetUseCaseProvider = Provider<CreatePetUseCase>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return CreatePetUseCase(repository);
});

final updatePetUseCaseProvider = Provider<UpdatePetUseCase>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return UpdatePetUseCase(repository);
});

final updatePetProfileUseCaseProvider = Provider<UpdatePetProfileUseCase>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return UpdatePetProfileUseCase(repository);
});

final deletePetUseCaseProvider = Provider<DeletePetUseCase>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return DeletePetUseCase(repository);
});

final manageFamilyManagersUseCaseProvider = Provider<ManageFamilyManagersUseCase>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return ManageFamilyManagersUseCase(repository);
});
