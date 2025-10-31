import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/core/services/logger_service.dart';
import '../../../../shared/domain/entities/pet_profile_entity.dart';

/// 백엔드 Pet API 서비스
///
/// BackendApiClient를 사용하여 펫 CRUD를 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendPetApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 모든 펫 목록 조회
  ///
  /// GET /pets
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      final response = await _apiClient.get('/pets');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<PetProfileEntity> pets = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              pets.add(_mapToPetEntity(item));
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              pets.add(_mapToPetEntity(item));
            }
          }
        }

        return Result.success('ペットリストを取得しました', pets);
      } else {
        return Result.failure('ペットリストの取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('펫 목록 조회', e);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ [PetAPI] getAllPets 에러: $e');
      }
      return Result.failure('ペットリストの取得に失敗しました: ${e.toString()}');
    }
  }

  /// 특정 펫 조회
  ///
  /// GET /pets/:id
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📡 [PetAPI] GET /pets/$id');
      }

      final response = await _apiClient.get('/pets/$id');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final pet = _mapToPetEntity(data['data'] ?? data);

          if (kDebugMode) {
            LoggerService.debug('✅ 펫 조회 성공: ${pet.name}');
          }

          return Result.success('ペット情報を取得しました', pet);
        }

        return Result.success('ペットが見つかりません', null);
      } else if (response.statusCode == 404) {
        return Result.success('ペットが見つかりません', null);
      } else {
        return Result.failure('ペット情報の取得に失敗しました');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success('ペットが見つかりません', null);
      }
      return _handleDioError('펫 조회', e);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ [PetAPI] getPetById 에러: $e');
      }
      return Result.failure('ペット情報の取得に失敗しました: ${e.toString()}');
    }
  }

  /// 펫 생성
  ///
  /// POST /pets
  /// Authorization 헤더는 자동으로 추가됨
  /// ownerId는 백엔드에서 토큰으로 자동 설정됨
  static Future<Result<PetProfileEntity>> createPet(
    PetProfileEntity pet,
  ) async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📡 [PetAPI] POST /pets');
      }

      final petData = _petEntityToMap(pet);
      final response = await _apiClient.post('/pets', data: petData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final createdPet = _mapToPetEntity(data['data'] ?? data);

          if (kDebugMode) {
            LoggerService.debug(
              '✅ 펫 생성 성공: ${createdPet.name} (${createdPet.id})',
            );
          }

          return Result.success('ペットを作成しました', createdPet);
        }

        return Result.failure('ペットの作成に失敗しました: 응답 데이터 없음');
      } else {
        return Result.failure('ペットの作成に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('펫 생성', e);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ [PetAPI] createPet 에러: $e');
      }
      return Result.failure('ペットの作成に失敗しました: ${e.toString()}');
    }
  }

  /// 펫 업데이트
  ///
  /// PUT /pets/:id
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<PetProfileEntity>> updatePet(
    PetProfileEntity pet,
  ) async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📡 [PetAPI] PUT /pets/${pet.id}');
      }

      final petData = _petEntityToMap(pet);
      final response = await _apiClient.put('/pets/${pet.id}', data: petData);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final updatedPet = _mapToPetEntity(data['data'] ?? data);

          if (kDebugMode) {
            LoggerService.debug('✅ 펫 업데이트 성공: ${updatedPet.name}');
          }

          return Result.success('ペット情報を更新しました', updatedPet);
        }

        return Result.failure('ペット情報の更新に失敗しました: 응답 데이터 없음');
      } else {
        return Result.failure('ペット情報の更新に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('펫 업데이트', e);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ [PetAPI] updatePet 에러: $e');
      }
      return Result.failure('ペット情報の更新に失敗しました: ${e.toString()}');
    }
  }

  /// 펫 삭제
  ///
  /// DELETE /pets/:id
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> deletePet(String id) async {
    try {
      if (kDebugMode) {
        LoggerService.debug('📡 [PetAPI] DELETE /pets/$id');
      }

      final response = await _apiClient.delete('/pets/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          LoggerService.debug('✅ 펫 삭제 성공: $id');
        }

        return Result.success('ペットを削除しました', null);
      } else {
        return Result.failure('ペットの削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('펫 삭제', e);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ [PetAPI] deletePet 에러: $e');
      }
      return Result.failure('ペットの削除に失敗しました: ${e.toString()}');
    }
  }

  /// 백엔드 응답 데이터를 PetProfileEntity로 변환
  static PetProfileEntity _mapToPetEntity(Map<String, dynamic> json) {
    return PetProfileEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? json['species']?.toString() ?? 'dog',
      breed: json['breed']?.toString(),
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate']) ?? DateTime.now()
          : DateTime.now(),
      gender: json['gender']?.toString() ?? 'male',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      size: json['size']?.toString(),
      microchipNumber: json['microchipNumber']?.toString(),
      arrivalDate: json['arrivalDate'] != null
          ? DateTime.tryParse(json['arrivalDate'])
          : null,
      neutered: json['neutered'] as bool?,
      imagePath: json['imageUrl']?.toString() ?? json['imagePath']?.toString(),
      ownerId: json['ownerId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  /// PetProfileEntity를 백엔드 요청 데이터로 변환
  static Map<String, dynamic> _petEntityToMap(PetProfileEntity pet) {
    return {
      'name': pet.name,
      'type': pet.type,
      'breed': pet.breed,
      'birthDate': pet.birthDate.toIso8601String(),
      'gender': pet.gender,
      'weight': pet.weight,
      'size': pet.size,
      'microchipNumber': pet.microchipNumber,
      'arrivalDate': pet.arrivalDate?.toIso8601String(),
      'neutered': pet.neutered,
      'imageUrl': pet.imagePath,
      'additionalInfo': pet.additionalInfo,
      // ownerId는 백엔드에서 토큰으로 자동 설정되므로 전송하지 않음
    };
  }

  /// DioException 에러 처리
  static Result<T> _handleDioError<T>(String operation, DioException e) {
    if (kDebugMode) {
      LoggerService.debug('❌ [$operation] DioException: ${e.type}');
      LoggerService.debug('   Status Code: ${e.response?.statusCode}');
      LoggerService.debug('   Message: ${e.message}');
    }

    String errorMessage = 'エラーが発生しました';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'タイムアウトが発生しました';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'ネットワーク接続を確認してください';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = '認証に失敗しました';
        } else if (statusCode == 403) {
          errorMessage = 'アクセスが拒否されました';
        } else if (statusCode == 404) {
          errorMessage = 'リソースが見つかりません';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'サーバーエラーが発生しました';
        }
        break;
      default:
        errorMessage = '予期しないエラーが発生しました';
    }

    return Result.failure(errorMessage);
  }
}
