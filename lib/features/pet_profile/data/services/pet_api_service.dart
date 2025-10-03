import 'dart:io';
import '../../../../shared/core/api/api_constants.dart';
import '../../../../shared/core/api/api_error_handler.dart';
import '../../../../shared/core/data/base_remote_data_source.dart';
import '../../../../shared/core/data/result_types.dart';
import '../../../../shared/core/domain/common_errors.dart';
import '../models/pet_profile_api_model.dart';

class PetApiService extends BaseRemoteDataSource<PetProfileApiModel> {
  PetApiService(super.apiClient);

  @override
  PetProfileApiModel fromJson(Map<String, dynamic> json) {
    return PetProfileApiModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(PetProfileApiModel data) {
    return data.toJson();
  }

  Future<ResultState<List<PetProfileApiModel>>> getAllPets({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await fetchPaginatedList(
        ApiEndpoints.pets,
        page: page,
        limit: limit,
      );

      return response;
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<PetProfileApiModel>> getPetById(String petId) async {
    try {
      final response = await fetchData(ApiEndpoints.petById(petId));
      return response;
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<PetProfileApiModel>> createPet(
    PetProfileCreateRequest request,
  ) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.pets,
        data: request.toJson(),
      );

      if (response.data == null) {
        return Failure(UnknownError(details: 'Empty response data'));
      }

      final petData = response.data!['data'] ?? response.data!;
      final pet = PetProfileApiModel.fromJson(petData);
      return Success(pet);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<PetProfileApiModel>> updatePet(
    String petId,
    PetProfileUpdateRequest request,
  ) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.petById(petId),
        data: request.toJson(),
      );

      if (response.data == null) {
        return Failure(UnknownError(details: 'Empty response data'));
      }

      final petData = response.data!['data'] ?? response.data!;
      final pet = PetProfileApiModel.fromJson(petData);
      return Success(pet);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> deletePet(String petId) async {
    try {
      await deleteData(ApiEndpoints.pets, petId);
      return const Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<PetImageUploadResponse>> uploadPetImage(
    String petId,
    File imageFile, {
    String? description,
  }) async {
    try {
      final response = await uploadFile(
        '${ApiEndpoints.petById(petId)}/image',
        imageFile.path,
        'image',
        additionalData: description != null
            ? {'description': description}
            : null,
      );

      if (response.isSuccess) {
        final uploadResponse = PetImageUploadResponse.fromJson(
          response.dataOrNull!,
        );
        return Success(uploadResponse);
      }

      return Failure(
        response.errorOrNull ?? UnknownError(details: 'Image upload failed'),
      );
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> updateSharingSettings(
    String petId,
    PetSharingSettings settings,
  ) async {
    try {
      await apiClient.put(
        '${ApiEndpoints.petById(petId)}/sharing',
        data: settings.toJson(),
      );
      return const Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<PetSharingSettings>> getSharingSettings(
    String petId,
  ) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.petById(petId)}/sharing',
      );

      if (response.data == null) {
        return Failure(UnknownError(details: 'Empty response data'));
      }

      final settingsData = response.data!['data'] ?? response.data!;
      final settings = PetSharingSettings.fromJson(settingsData);
      return Success(settings);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> addFamilyManager(
    String petId,
    String userId,
  ) async {
    try {
      await apiClient.post(
        '${ApiEndpoints.petById(petId)}/family-managers',
        data: {'user_id': userId},
      );
      return const Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> removeFamilyManager(
    String petId,
    String userId,
  ) async {
    try {
      await apiClient.delete(
        '${ApiEndpoints.petById(petId)}/family-managers/$userId',
      );
      return const Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<List<String>>> getFamilyManagers(String petId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.petById(petId)}/family-managers',
      );

      if (response.data == null) {
        return Failure(UnknownError(details: 'Empty response data'));
      }

      final managersData = response.data!['data'] ?? response.data!;
      final managers = List<String>.from(managersData['family_managers'] ?? []);
      return Success(managers);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<PetSyncStatus>> getSyncStatus(String petId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.petById(petId)}/sync-status',
      );

      if (response.data == null) {
        return Failure(UnknownError(details: 'Empty response data'));
      }

      final statusData = response.data!['data'] ?? response.data!;
      final status = PetSyncStatus.fromJson(statusData);
      return Success(status);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<List<PetProfileApiModel>>> searchPets({
    String? name,
    String? type,
    String? breed,
    String? ownerId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (name != null) queryParams['name'] = name;
      if (type != null) queryParams['type'] = type;
      if (breed != null) queryParams['breed'] = breed;
      if (ownerId != null) queryParams['owner_id'] = ownerId;

      final response = await fetchPaginatedList(
        '${ApiEndpoints.pets}/search',
        queryParameters: queryParams,
      );

      return response;
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<List<PetProfileApiModel>>> getSharedPets({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await fetchPaginatedList(
        '${ApiEndpoints.pets}/shared',
        page: page,
        limit: limit,
      );

      return response;
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }

  Future<ResultState<void>> bulkUpdatePets(
    List<PetProfileUpdateRequest> updates,
  ) async {
    try {
      await apiClient.post(
        '${ApiEndpoints.pets}/bulk-update',
        data: {'updates': updates.map((update) => update.toJson()).toList()},
      );
      return const Success(null);
    } catch (e) {
      return Failure(ApiErrorHandler.handleError(e));
    }
  }
}
