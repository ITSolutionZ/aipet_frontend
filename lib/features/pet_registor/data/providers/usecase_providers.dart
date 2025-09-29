import 'package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/create_pet_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/delete_pet_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/get_all_pets_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/update_pet_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UseCase 프로바이더들
final getAllPetsUseCaseProvider = Provider<GetAllPetsUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return GetAllPetsUseCase(repository);
});

final getPetByIdUseCaseProvider = Provider<GetPetByIdUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return GetPetByIdUseCase(repository);
});

final createPetUseCaseProvider = Provider<CreatePetUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return CreatePetUseCase(repository);
});

final updatePetUseCaseProvider = Provider<UpdatePetUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return UpdatePetUseCase(repository);
});

final deletePetUseCaseProvider = Provider<DeletePetUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return DeletePetUseCase(repository);
});
