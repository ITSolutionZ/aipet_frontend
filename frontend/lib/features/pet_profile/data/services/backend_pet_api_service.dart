import 'package:dio/dio.dart';


import '../../../../shared/shared.dart';
import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
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
      return Result.failure('ペットリストの取得に失敗しました');
    }
  }

  /// 특정 펫 조회
  ///
  /// GET /pets/:id
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      final response = await _apiClient.get('/pets/$id');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final pet = _mapToPetEntity(data['data'] ?? data);
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
      return Result.failure('ペット情報の取得に失敗しました');
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
      LoggerService.debug('📡 [PetAPI] createPet 호출 - name: ${pet.name}');

      final petData = _petEntityToMap(pet);
      LoggerService.debug('📤 [PetAPI] Request data: $petData');

      final response = await _apiClient.post('/pets', data: petData);

      LoggerService.debug('📥 [PetAPI] Response: statusCode=${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final createdPet = _mapToPetEntity(data['data'] ?? data);
          LoggerService.debug('✅ [PetAPI] Pet created: ${createdPet.id}');
          return Result.success('ペットを作成しました', createdPet);
        }

        LoggerService.debug('⚠️ [PetAPI] Invalid response format');
        return Result.failure('ペットの作成に失敗しました');
      } else {
        LoggerService.debug('❌ [PetAPI] Bad status code: ${response.statusCode}');
        return Result.failure('ペットの作成に失敗しました');
      }
    } on DioException catch (e) {
      LoggerService.debug('❌ [PetAPI] DioException: ${e.type}, ${e.message}');
      LoggerService.debug('   Response: ${e.response?.data}');
      return _handleDioError('펫 생성', e);
    } catch (e) {
      LoggerService.debug('❌ [PetAPI] Unexpected error: $e');
      return Result.failure('ペットの作成に失敗しました: $e');
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
      final petData = _petEntityToMap(pet);
      final response = await _apiClient.put('/pets/${pet.id}', data: petData);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final updatedPet = _mapToPetEntity(data['data'] ?? data);
          return Result.success('ペット情報を更新しました', updatedPet);
        }

        return Result.failure('ペット情報の更新に失敗しました');
      } else {
        return Result.failure('ペット情報の更新に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('펫 업데이트', e);
    } catch (e) {
      return Result.failure('ペット情報の更新に失敗しました');
    }
  }

  /// 펫 삭제
  ///
  /// DELETE /pets/:id
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> deletePet(String id) async {
    try {
      final response = await _apiClient.delete('/pets/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('ペットを削除しました', null);
      } else {
        return Result.failure('ペットの削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('펫 삭제', e);
    } catch (e) {
      return Result.failure('ペットの削除に失敗しました');
    }
  }

  /// 백엔드 응답 데이터를 PetProfileEntity로 변환
  /// Backend는 snake_case를 사용 (birth_date, microchip_number 등)
  static PetProfileEntity _mapToPetEntity(Map<String, dynamic> json) {
    return PetProfileEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'dog',
      breed: json['breed']?.toString(),
      birthDate: (json['birth_date'] ?? json['birthDate']) != null
          ? DateTime.tryParse((json['birth_date'] ?? json['birthDate']).toString()) ?? DateTime.now()
          : DateTime.now(),
      gender: _convertGenderFromBackend(json['gender']?.toString() ?? 'unknown'),
      weight: _parseDouble(json['weight']) ?? 0.0,
      size: json['size']?.toString(),
      microchipNumber: (json['microchip_number'] ?? json['microchipNumber'])?.toString(),
      arrivalDate: (json['arrival_date'] ?? json['arrivalDate']) != null
          ? DateTime.tryParse((json['arrival_date'] ?? json['arrivalDate']).toString())
          : null,
      neutered: _parseBool(json['is_neutered'] ?? json['neutered']),
      imagePath: (json['photo_url'] ?? json['imageUrl'] ?? json['imagePath'])?.toString(),
      ownerId: (json['owner_id'] ?? json['ownerId'])?.toString() ?? '',
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.tryParse((json['updated_at'] ?? json['updatedAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: _parseBool(json['is_active'] ?? json['isActive']) ?? true,
      additionalInfo: {
        if (json['color'] != null) 'color': json['color'],
        if (json['notes'] != null) 'notes': json['notes'],
        ...(json['additionalInfo'] as Map<String, dynamic>? ?? {}),
      },
    );
  }

  /// 안전한 bool 파싱 (int 1/0 또는 bool 처리)
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return null;
  }

  /// 안전한 double 파싱
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// PetProfileEntity를 백엔드 요청 데이터로 변환
  /// Backend는 snake_case를 사용
  static Map<String, dynamic> _petEntityToMap(PetProfileEntity pet) {
    return {
      if (pet.id.isNotEmpty) 'id': pet.id,
      'name': pet.name,
      'type': pet.type,
      if (pet.breed != null) 'breed': pet.breed,
      'birthDate': pet.birthDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'gender': _convertGenderToBackend(pet.gender),
      if (pet.weight > 0) 'weight': pet.weight,
      if (pet.imagePath != null) 'photoUrl': pet.imagePath,
      if (pet.microchipNumber != null) 'microchipNumber': pet.microchipNumber,
      if (pet.neutered != null) 'isNeutered': pet.neutered,
      if (pet.additionalInfo?['color'] != null)
        'color': pet.additionalInfo!['color'],
      if (pet.additionalInfo?['notes'] != null)
        'notes': pet.additionalInfo!['notes'],
      // ownerId는 백엔드에서 토큰으로 자동 설정되므로 전송하지 않음
    };
  }

  /// 일본어 gender를 백엔드 형식으로 변환
  /// オス -> male, メス -> female, その他 -> unknown
  static String _convertGenderToBackend(String gender) {
    switch (gender) {
      case 'オス':
        return 'male';
      case 'メス':
        return 'female';
      default:
        return 'unknown';
    }
  }

  /// 백엔드 gender를 일본어로 변환
  /// male -> オス, female -> メス, unknown -> その他
  static String _convertGenderFromBackend(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'オス';
      case 'female':
        return 'メス';
      default:
        return 'その他';
    }
  }

  /// DioException 에러 처리
  static Result<T> _handleDioError<T>(String operation, DioException e) {
    String errorMessage = 'エラーが発生しました';

    LoggerService.debug('❌ [PetAPI] $operation 에러 발생');
    LoggerService.debug('   - Type: ${e.type}');
    LoggerService.debug('   - Message: ${e.message}');
    LoggerService.debug('   - StatusCode: ${e.response?.statusCode}');
    LoggerService.debug('   - Response: ${e.response?.data}');

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
        final responseData = e.response?.data;

        if (statusCode == 400 && responseData is Map<String, dynamic>) {
          // Validation 에러 상세 정보 표시
          if (responseData['errors'] != null) {
            final errors = responseData['errors'] as List;
            final errorFields = errors.map((err) => '${err['field']}: ${err['message']}').join('\n');
            errorMessage = '入力データエラー:\n$errorFields';
          } else if (responseData['error'] != null) {
            errorMessage = responseData['error'].toString();
          }
        } else if (statusCode == 401) {
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

    LoggerService.debug('   - Final error message: $errorMessage');
    return Result.failure(errorMessage);
  }
}
