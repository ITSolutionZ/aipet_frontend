import 'package:dio/dio.dart';

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
      print('🐾 ===== Backend Pet API Create 시작 =====');
      print('🐾 펫 이름: ${pet.name}');
      print('🐾 펫 타입: ${pet.type}');
      print('🐾 펫 품종: ${pet.breed}');
      print('🐾 원본 gender: ${pet.gender}');
      LoggerService.debug('🐾 ===== Backend Pet Create 시작 =====');
      LoggerService.debug('🐾 펫 이름: ${pet.name}');
      LoggerService.debug('🐾 펫 타입: ${pet.type}');
      LoggerService.debug('🐾 펫 품종: ${pet.breed}');
      LoggerService.debug('🐾 원본 gender: ${pet.gender}');

      final petData = _petEntityToMap(pet);
      print('🐾 전송할 데이터: $petData');
      print('🐾 변환된 gender: ${petData['gender']}');
      LoggerService.debug('🐾 전송할 데이터: $petData');
      LoggerService.debug('🐾 변환된 gender: ${petData['gender']}');

      print('🐾 API 호출 중: POST /pets');
      // 타임아웃을 더 길게 설정 (TestFlight 환경 고려)
      final response = await _apiClient.post(
        '/pets',
        data: petData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      print('🐾 Response Status: ${response.statusCode}');
      print('🐾 Response Data: ${response.data}');
      LoggerService.debug('🐾 Response Status: ${response.statusCode}');
      LoggerService.debug('🐾 Response Data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          try {
            print('🔍 변환 시작 - data[\'data\']: ${data['data']}');
            final createdPet = _mapToPetEntity(data['data'] ?? data);
            print('✅ Backend API - 펫 생성 성공: ${createdPet.id}');
            LoggerService.debug('✅ 펫 생성 성공: ${createdPet.id}');
            return Result.success('ペットを作成しました', createdPet);
          } catch (e, stackTrace) {
            print('❌ 펫 엔티티 변환 실패: $e');
            print('   Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
            LoggerService.debug('❌ 펫 엔티티 변환 실패: $e');
            return Result.failure('ペットの作成に失敗しました: 데이터 변환 오류');
          }
        }

        print('❌ Response data 형식 오류');
        LoggerService.debug('❌ Response data 형식 오류');
        return Result.failure('ペットの作成に失敗しました');
      } else {
        print('❌ Status Code 오류: ${response.statusCode}');
        LoggerService.debug('❌ Status Code 오류: ${response.statusCode}');
        return Result.failure('ペットの作成に失敗しました');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Request Path: ${e.requestOptions.path}');
      LoggerService.debug('❌ DioException 발생');
      LoggerService.debug('   Type: ${e.type}');
      LoggerService.debug('   Status: ${e.response?.statusCode}');
      LoggerService.debug('   Message: ${e.message}');
      LoggerService.debug('   Response: ${e.response?.data}');
      LoggerService.debug('   Request Path: ${e.requestOptions.path}');

      // 타임아웃 에러인 경우 더 구체적인 메시지
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        LoggerService.debug('⏰ 타임아웃 에러 - 네트워크 연결 확인 필요');
      }

      return _handleDioError('펫 생성', e);
    } catch (e, stackTrace) {
      print('❌ 알 수 없는 에러: $e');
      print('   Type: ${e.runtimeType}');
      print('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      LoggerService.debug('❌ 알 수 없는 에러: $e');
      LoggerService.debug('   Type: ${e.runtimeType}');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
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
  static PetProfileEntity _mapToPetEntity(Map<String, dynamic> json) {
    // 백엔드는 snake_case를 사용하므로 두 가지 형식 모두 지원
    return PetProfileEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? json['species']?.toString() ?? 'dog',
      breed: json['breed']?.toString(),
      birthDate: (json['birthDate'] != null
              ? DateTime.tryParse(json['birthDate'])
              : json['birth_date'] != null
                  ? DateTime.tryParse(json['birth_date'])
                  : null) ??
          DateTime.now(),
      gender: json['gender']?.toString() ?? 'male',
      weight: _parseDouble(json['weight']) ?? 0.0,
      size: json['size']?.toString(),
      microchipNumber: json['microchipNumber']?.toString() ??
          json['microchip_number']?.toString(),
      arrivalDate: json['arrivalDate'] != null
          ? DateTime.tryParse(json['arrivalDate'])
          : json['arrival_date'] != null
              ? DateTime.tryParse(json['arrival_date'])
              : null,
      // 백엔드는 0/1을 사용, 프론트엔드는 bool 사용
      neutered: json['neutered'] != null
          ? (json['neutered'] is bool
              ? json['neutered'] as bool
              : (json['neutered'] as num) == 1)
          : json['is_neutered'] != null
              ? (json['is_neutered'] is bool
                  ? json['is_neutered'] as bool
                  : (json['is_neutered'] as num) == 1)
              : null,
      imagePath: json['imageUrl']?.toString() ??
          json['image_url']?.toString() ??
          json['photo_url']?.toString() ??
          json['imagePath']?.toString(),
      ownerId: json['ownerId']?.toString() ??
          json['owner_id']?.toString() ??
          '',
      createdAt: (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : json['created_at'] != null
                  ? DateTime.tryParse(json['created_at'])
                  : null) ??
          DateTime.now(),
      updatedAt: (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : json['updated_at'] != null
                  ? DateTime.tryParse(json['updated_at'])
                  : null) ??
          DateTime.now(),
      // 백엔드는 0/1을 사용, 프론트엔드는 bool 사용
      isActive: json['isActive'] != null
          ? (json['isActive'] is bool
              ? json['isActive'] as bool
              : (json['isActive'] as num) == 1)
          : json['is_active'] != null
              ? (json['is_active'] is bool
                  ? json['is_active'] as bool
                  : (json['is_active'] as num) == 1)
              : true,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ??
          json['additional_info'] as Map<String, dynamic>?,
    );
  }

  /// PetProfileEntity를 백엔드 요청 데이터로 변환
  static Map<String, dynamic> _petEntityToMap(PetProfileEntity pet) {
    // gender 값을 영문으로 변환 (일본어 → 영문)
    final genderMap = {
      'オス': 'male',
      'メス': 'female',
      '未確認': 'unknown',
      'male': 'male',
      'female': 'female',
      'unknown': 'unknown',
    };
    final normalizedGender = genderMap[pet.gender] ?? 'unknown';

    final data = {
      'name': pet.name,
      'type': pet.type,
      'breed': pet.breed,
      'birthDate': pet.birthDate.toIso8601String(),
      'gender': normalizedGender,
      'weight': pet.weight,
      'additionalInfo': pet.additionalInfo,
      // ownerId는 백엔드에서 토큰으로 자동 설정되므로 전송하지 않음
    };

    // null이 아닌 선택적 필드만 추가
    if (pet.size != null) {
      data['size'] = pet.size;
    }
    if (pet.microchipNumber != null && pet.microchipNumber!.isNotEmpty) {
      data['microchipNumber'] = pet.microchipNumber;
    }
    if (pet.arrivalDate != null) {
      data['arrivalDate'] = pet.arrivalDate!.toIso8601String();
    }
    if (pet.neutered != null) {
      data['neutered'] = pet.neutered;
    }
    if (pet.imagePath != null && pet.imagePath!.isNotEmpty) {
      data['imageUrl'] = pet.imagePath;
    }

    return data;
  }

  /// 안전한 double 파싱 헬퍼
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// DioException 에러 처리
  static Result<T> _handleDioError<T>(String operation, DioException e) {
    String errorMessage = 'エラーが発生しました';

    switch (e.type) {
      case DioExceptionType.cancel:
        // Firebase 인증 에러 또는 요청 취소
        if (e.error is String) {
          errorMessage = e.error as String;
        } else {
          errorMessage = 'リクエストがキャンセルされました';
        }
        // TestFlight 환경에서도 명확한 메시지 제공
        if (e.response?.statusCode == 401 || e.error.toString().contains('Firebase')) {
          errorMessage = '認証に失敗しました。再度ログインしてください。';
        }
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'タイムアウトが発生しました';
        break;
      case DioExceptionType.connectionError:
        if (e.message?.contains('Connection refused') == true) {
          errorMessage = 'サーバーに接続できません。サーバーが起動しているか確認してください。';
        } else {
          errorMessage = 'ネットワーク接続を確認してください';
        }
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          // 백엔드 유효성 검증 에러 메시지 추출
          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            // errors 배열에서 구체적인 필드별 에러 메시지 추출
            if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
              final errors = data['errors'] as List;
              final errorMessages = <String>[];

              for (final error in errors) {
                if (error is Map<String, dynamic>) {
                  final field = error['field'] as String? ?? '';
                  final message = error['message'] as String? ?? error['msg'] as String? ?? '';

                  // 필드명을 일본어로 변환
                  final fieldName = _getFieldNameInJapanese(field);

                  if (message.isNotEmpty) {
                    errorMessages.add('$fieldName: $message');
                  } else if (field.isNotEmpty) {
                    errorMessages.add('$fieldNameが正しくありません');
                  }
                }
              }

              if (errorMessages.isNotEmpty) {
                errorMessage = '入力内容を確認してください:\n• ${errorMessages.join('\n• ')}';
              } else {
                errorMessage = data['error'] as String? ?? '入力データが正しくありません';
              }
            } else if (data['error'] != null) {
              errorMessage = data['error'] as String;
            } else if (data['message'] != null) {
              errorMessage = data['message'] as String;
            } else {
              errorMessage = '入力データが正しくありません。入力内容を確認してから再度お試しください。';
            }
          } else {
            errorMessage = '入力データが正しくありません。入力内容を確認してから再度お試しください。';
          }
        } else if (statusCode == 401) {
          errorMessage = '認証に失敗しました。再度ログインしてください。';
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

  /// 필드명을 일본어로 변환하는 헬퍼 메서드
  static String _getFieldNameInJapanese(String field) {
    final fieldMap = {
      'name': 'ペットの名前',
      'type': 'ペットの種類',
      'breed': '品種',
      'birthDate': '生年月日',
      'birth_date': '生年月日',
      'gender': '性別',
      'weight': '体重',
      'size': 'サイズ',
      'microchipNumber': 'マイクロチップ番号',
      'microchip_number': 'マイクロチップ番号',
      'arrivalDate': '家にきた日',
      'arrival_date': '家にきた日',
      'neutered': '去勢・避妊',
      'is_neutered': '去勢・避妊',
      'imageUrl': '画像',
      'image_url': '画像',
      'photo_url': '画像',
      'additionalInfo': '追加情報',
      'additional_info': '追加情報',
    };

    return fieldMap[field] ?? field;
  }
}
