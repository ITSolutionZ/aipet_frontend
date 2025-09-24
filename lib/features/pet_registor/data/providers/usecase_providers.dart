import 'package:aipet_frontend/features/onboarding/domain/usecases/usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pet_providers.dart';

/// UseCase Provider들
/// Dependency Injection을 위한 Provider 정의

/// GetAllPetsUseCase Provider
final getAllPetsUseCaseProvider = Provider<GetAllPetsUseCase>((ref) {
  final repository = ref.read(petRepositoryProvider);
  return GetAllPetsUseCase(repository);
});

/// GetPetByIdUseCase Provider
final getPetByIdUseCaseProvider = Provider<GetPetByIdUseCase>((ref) {
  final repository = ref.read(petRepositoryProvider);
  return GetPetByIdUseCase(repository);
});

/// CreatePetUseCase Provider
final createPetUseCaseProvider = Provider<CreatePetUseCase>((ref) {
  final repository = ref.read(petRepositoryProvider);
  return CreatePetUseCase(repository);
});

/// UpdatePetUseCase Provider
final updatePetUseCaseProvider = Provider<UpdatePetUseCase>((ref) {
  final repository = ref.read(petRepositoryProvider);
  return UpdatePetUseCase(repository);
});

/// DeletePetUseCase Provider
final deletePetUseCaseProvider = Provider<DeletePetUseCase>((ref) {
  final repository = ref.read(petRepositoryProvider);
  return DeletePetUseCase(repository);
});
