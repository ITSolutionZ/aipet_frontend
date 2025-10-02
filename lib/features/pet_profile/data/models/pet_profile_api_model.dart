import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/entities/pet_profile_entity.dart';

part 'pet_profile_api_model.freezed.dart';
part 'pet_profile_api_model.g.dart';

@freezed
class PetProfileApiModel with _$PetProfileApiModel {
  const factory PetProfileApiModel({
    required String id,
    required String name,
    required String type,
    String? breed,
    required String birthDate,
    required String gender,
    required double weight,
    String? size,
    String? microchipNumber,
    String? arrivalDate,
    bool? neutered,
    String? imageUrl,
    String? imagePath,
    required String ownerId,
    required String createdAt,
    required String updatedAt,
    @Default(true) bool isActive,
    Map<String, dynamic>? additionalInfo,
    List<String>? familyManagerIds,
    bool? isPublic,
    int? version,
    String? lastSyncedAt,
  }) = _PetProfileApiModel;

  const PetProfileApiModel._();

  factory PetProfileApiModel.fromJson(Map<String, dynamic> json) =>
      _$PetProfileApiModelFromJson(json);

  PetProfileEntity toDomain() {
    return PetProfileEntity(
      id: id,
      name: name,
      type: type,
      breed: breed,
      birthDate: DateTime.parse(birthDate),
      gender: gender,
      weight: weight,
      size: size,
      microchipNumber: microchipNumber,
      arrivalDate: arrivalDate != null ? DateTime.parse(arrivalDate!) : null,
      neutered: neutered,
      imagePath: imageUrl ?? imagePath,
      ownerId: ownerId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isActive: isActive,
      additionalInfo: additionalInfo,
    );
  }

  factory PetProfileApiModel.fromDomain(PetProfileEntity entity) {
    return PetProfileApiModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      breed: entity.breed,
      birthDate: entity.birthDate.toIso8601String(),
      gender: entity.gender,
      weight: entity.weight,
      size: entity.size,
      microchipNumber: entity.microchipNumber,
      arrivalDate: entity.arrivalDate?.toIso8601String(),
      neutered: entity.neutered,
      imagePath: entity.imagePath,
      ownerId: entity.ownerId,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      isActive: entity.isActive,
      additionalInfo: entity.additionalInfo,
    );
  }

  factory PetProfileApiModel.fromDomainWithSync({
    required PetProfileEntity entity,
    String? imageUrl,
    List<String>? familyManagerIds,
    bool? isPublic,
    int? version,
  }) {
    return PetProfileApiModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      breed: entity.breed,
      birthDate: entity.birthDate.toIso8601String(),
      gender: entity.gender,
      weight: entity.weight,
      size: entity.size,
      microchipNumber: entity.microchipNumber,
      arrivalDate: entity.arrivalDate?.toIso8601String(),
      neutered: entity.neutered,
      imageUrl: imageUrl,
      imagePath: entity.imagePath,
      ownerId: entity.ownerId,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      isActive: entity.isActive,
      additionalInfo: entity.additionalInfo,
      familyManagerIds: familyManagerIds,
      isPublic: isPublic,
      version: version,
      lastSyncedAt: DateTime.now().toIso8601String(),
    );
  }
}

@freezed
class PetImageUploadResponse with _$PetImageUploadResponse {
  const factory PetImageUploadResponse({
    required String imageUrl,
    required String imageId,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) = _PetImageUploadResponse;

  factory PetImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$PetImageUploadResponseFromJson(json);
}

@freezed
class PetProfileCreateRequest with _$PetProfileCreateRequest {
  const factory PetProfileCreateRequest({
    required String name,
    required String type,
    String? breed,
    required String birthDate,
    required String gender,
    required double weight,
    String? size,
    String? microchipNumber,
    String? arrivalDate,
    bool? neutered,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) = _PetProfileCreateRequest;

  factory PetProfileCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PetProfileCreateRequestFromJson(json);

  factory PetProfileCreateRequest.fromDomain(PetProfileEntity entity) {
    return PetProfileCreateRequest(
      name: entity.name,
      type: entity.type,
      breed: entity.breed,
      birthDate: entity.birthDate.toIso8601String(),
      gender: entity.gender,
      weight: entity.weight,
      size: entity.size,
      microchipNumber: entity.microchipNumber,
      arrivalDate: entity.arrivalDate?.toIso8601String(),
      neutered: entity.neutered,
      imageUrl: entity.imagePath,
      additionalInfo: entity.additionalInfo,
    );
  }
}

@freezed
class PetProfileUpdateRequest with _$PetProfileUpdateRequest {
  const factory PetProfileUpdateRequest({
    String? name,
    String? breed,
    String? birthDate,
    String? gender,
    double? weight,
    String? size,
    String? microchipNumber,
    String? arrivalDate,
    bool? neutered,
    String? imageUrl,
    bool? isActive,
    Map<String, dynamic>? additionalInfo,
    int? version,
  }) = _PetProfileUpdateRequest;

  factory PetProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PetProfileUpdateRequestFromJson(json);
}

@freezed
class PetSharingSettings with _$PetSharingSettings {
  const factory PetSharingSettings({
    required String petId,
    required bool isPublic,
    List<String>? allowedUserIds,
    List<String>? familyManagerIds,
    Map<String, dynamic>? permissions,
  }) = _PetSharingSettings;

  factory PetSharingSettings.fromJson(Map<String, dynamic> json) =>
      _$PetSharingSettingsFromJson(json);
}

@freezed
class PetSyncStatus with _$PetSyncStatus {
  const factory PetSyncStatus({
    required String petId,
    required bool isSynced,
    String? lastSyncedAt,
    int? localVersion,
    int? remoteVersion,
    bool? hasConflicts,
    List<String>? conflictFields,
  }) = _PetSyncStatus;

  factory PetSyncStatus.fromJson(Map<String, dynamic> json) =>
      _$PetSyncStatusFromJson(json);
}
