import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pet_profile_entity.dart';
import '../domain/result.dart';
import 'firebase_token_service.dart';
import 'logger_service.dart';

/// Firebase Firestore를 사용한 Pet 데이터 서비스
///
/// 백엔드 API 대신 Firebase Firestore를 사용하여 펫 데이터를 관리합니다.
class FirestorePetService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'pets';

  /// 현재 사용자 ID 가져오기
  static String? get _currentUserId {
    return FirebaseTokenService.getCurrentUserId();
  }

  /// 모든 펫 목록 조회
  ///
  /// 현재 로그인한 사용자의 펫만 조회합니다.
  /// 인덱스 없이 작동하도록 orderBy를 제거하고 클라이언트에서 정렬합니다.
  static Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        LoggerService.debug('⚠️ Firestore: 로그인 필요 - 빈 리스트 반환');
        return Result.success('ペットがいません', []);
      }

      LoggerService.debug('📡 Firestore: 펫 목록 조회 시작 (userId: $userId)');

      // 인덱스 불필요: where만 사용하고 클라이언트에서 정렬
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('ownerId', isEqualTo: userId)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              LoggerService.debug('⚠️ Firestore: 펫 목록 조회 타임아웃 (5초)');
              throw Exception('タイムアウト');
            },
          );

      final pets = <PetProfileEntity>[];

      for (final doc in querySnapshot.docs) {
        try {
          final pet = _mapToPetEntity(doc.id, doc.data());
          pets.add(pet);
        } catch (e) {
          LoggerService.debug('⚠️ Firestore: 펫 데이터 변환 실패 (${doc.id}): $e');
        }
      }

      // 클라이언트에서 createdAt 기준 내림차순 정렬
      pets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      LoggerService.debug('✅ Firestore: 펫 목록 조회 성공 (${pets.length}개)');
      return Result.success('ペットリストを取得しました', pets);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ Firestore: 펫 목록 조회 실패: $e');
      LoggerService.debug(
        '   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}',
      );
      // 에러 발생 시 빈 리스트 반환 (앱이 크래시되지 않도록)
      return Result.success('ペットがいません', []);
    }
  }

  /// 특정 펫 조회
  ///
  /// GET /pets/:id
  static Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        LoggerService.debug('⚠️ Firestore: 로그인 필요 (currentUserId is null)');
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firestore: 펫 조회 시작 (id: $id)');
      LoggerService.debug('   현재 로그인 userId: $userId');

      final doc = await _firestore.collection(_collectionName).doc(id).get();

      if (!doc.exists) {
        LoggerService.debug('⚠️ Firestore: 펫을 찾을 수 없음 (id: $id)');
        return Result.success('ペットが見つかりません', null);
      }

      final data = doc.data();
      if (data == null) {
        return Result.success('ペットが見つかりません', null);
      }

      // 소유자 확인
      final petOwnerId = data['ownerId'];
      LoggerService.debug('   펫의 ownerId: $petOwnerId');
      if (petOwnerId != userId) {
        LoggerService.debug('⚠️ Firestore: 권한 없음 - userId($userId) != ownerId($petOwnerId)');
        return Result.failure('このペットにアクセスする権限がありません');
      }

      final pet = _mapToPetEntity(doc.id, data);
      LoggerService.debug('✅ Firestore: 펫 조회 성공 (id: $id)');
      return Result.success('ペット情報を取得しました', pet);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ Firestore: 펫 조회 실패 (id: $id): $e');
      LoggerService.debug(
        '   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}',
      );
      return Result.failure('ペット情報の取得に失敗しました: $e');
    }
  }

  /// 펫 생성
  ///
  /// POST /pets
  static Future<Result<PetProfileEntity>> createPet(
    PetProfileEntity pet,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firestore: 펫 생성 시작');
      LoggerService.debug('   이름: ${pet.name}, 타입: ${pet.type}');

      final petData = _petEntityToMap(pet, userId);
      final now = FieldValue.serverTimestamp();

      // createdAt, updatedAt 추가
      petData['createdAt'] = now;
      petData['updatedAt'] = now;

      // Firestore에 추가 (ID 자동 생성)
      final docRef = await _firestore.collection(_collectionName).add(petData);

      // 생성된 문서 조회
      final doc = await docRef.get();
      final createdData = doc.data();
      if (createdData == null) {
        return Result.failure('ペットの作成に失敗しました');
      }

      // Timestamp를 DateTime으로 변환
      final createdPet = _mapToPetEntity(doc.id, createdData);

      LoggerService.debug('✅ Firestore: 펫 생성 성공 (id: ${doc.id})');
      return Result.success('ペットを作成しました', createdPet);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ Firestore: 펫 생성 실패: $e');
      LoggerService.debug(
        '   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}',
      );
      return Result.failure('ペットの作成に失敗しました: $e');
    }
  }

  /// 펫 업데이트
  ///
  /// PUT /pets/:id
  static Future<Result<PetProfileEntity>> updatePet(
    PetProfileEntity pet,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firestore: 펫 업데이트 시작 (id: ${pet.id})');

      // 소유자 확인
      final doc = await _firestore
          .collection(_collectionName)
          .doc(pet.id)
          .get();
      if (!doc.exists) {
        return Result.failure('ペットが見つかりません');
      }

      final data = doc.data();
      if (data == null || data['ownerId'] != userId) {
        return Result.failure('このペットを更新する権限がありません');
      }

      final petData = _petEntityToMap(pet, userId);
      petData['updatedAt'] = FieldValue.serverTimestamp();

      // id와 ownerId는 업데이트하지 않음
      petData.remove('id');
      petData.remove('ownerId');

      await _firestore.collection(_collectionName).doc(pet.id).update(petData);

      // 업데이트된 문서 조회
      final updatedDoc = await _firestore
          .collection(_collectionName)
          .doc(pet.id)
          .get();
      final updatedData = updatedDoc.data();
      if (updatedData == null) {
        return Result.failure('ペット情報の更新に失敗しました');
      }

      final updatedPet = _mapToPetEntity(pet.id, updatedData);

      LoggerService.debug('✅ Firestore: 펫 업데이트 성공 (id: ${pet.id})');
      return Result.success('ペット情報を更新しました', updatedPet);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ Firestore: 펫 업데이트 실패 (id: ${pet.id}): $e');
      LoggerService.debug(
        '   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}',
      );
      return Result.failure('ペット情報の更新に失敗しました: $e');
    }
  }

  /// 펫 삭제
  ///
  /// DELETE /pets/:id
  static Future<Result<void>> deletePet(String id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 Firestore: 펫 삭제 시작 (id: $id)');

      // 소유자 확인
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) {
        return Result.failure('ペットが見つかりません');
      }

      final data = doc.data();
      if (data == null || data['ownerId'] != userId) {
        return Result.failure('このペットを削除する権限がありません');
      }

      await _firestore.collection(_collectionName).doc(id).delete();

      LoggerService.debug('✅ Firestore: 펫 삭제 성공 (id: $id)');
      return Result.success('ペットを削除しました', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ Firestore: 펫 삭제 실패 (id: $id): $e');
      LoggerService.debug(
        '   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}',
      );
      return Result.failure('ペットの削除に失敗しました: $e');
    }
  }

  /// Firestore 데이터를 PetProfileEntity로 변환
  static PetProfileEntity _mapToPetEntity(
    String id,
    Map<String, dynamic> data,
  ) {
    // Timestamp를 DateTime으로 변환
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return PetProfileEntity(
      id: id,
      name: data['name']?.toString() ?? '',
      type: data['type']?.toString() ?? 'dog',
      breed: data['breed']?.toString(),
      birthDate: parseTimestamp(data['birthDate']) ?? DateTime.now(),
      gender: data['gender']?.toString() ?? 'male',
      weight: _parseDouble(data['weight']) ?? 0.0,
      size: data['size']?.toString(),
      microchipNumber: data['microchipNumber']?.toString(),
      arrivalDate: parseTimestamp(data['arrivalDate']),
      neutered: data['neutered'] is bool
          ? data['neutered'] as bool
          : (data['neutered'] as num?)?.toInt() == 1,
      imagePath: data['imageUrl']?.toString() ?? data['imagePath']?.toString(),
      ownerId: data['ownerId']?.toString() ?? '',
      createdAt: parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      isActive: data['isActive'] is bool
          ? data['isActive'] as bool
          : (data['isActive'] as num?)?.toInt() != 0,
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  /// PetProfileEntity를 Firestore 데이터로 변환
  static Map<String, dynamic> _petEntityToMap(
    PetProfileEntity pet,
    String userId,
  ) {
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

    final data = <String, dynamic>{
      'name': pet.name,
      'type': pet.type,
      'breed': pet.breed,
      'birthDate': Timestamp.fromDate(pet.birthDate),
      'gender': normalizedGender,
      'weight': pet.weight,
      'ownerId': userId,
      'isActive': pet.isActive,
    };

    // null이 아닌 선택적 필드만 추가
    if (pet.size != null) {
      data['size'] = pet.size;
    }
    if (pet.microchipNumber != null && pet.microchipNumber!.isNotEmpty) {
      data['microchipNumber'] = pet.microchipNumber;
    }
    if (pet.arrivalDate != null) {
      data['arrivalDate'] = Timestamp.fromDate(pet.arrivalDate!);
    }
    if (pet.neutered != null) {
      data['neutered'] = pet.neutered;
    }
    if (pet.imagePath != null && pet.imagePath!.isNotEmpty) {
      data['imageUrl'] = pet.imagePath;
    }
    if (pet.additionalInfo != null) {
      data['additionalInfo'] = pet.additionalInfo;
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
}
