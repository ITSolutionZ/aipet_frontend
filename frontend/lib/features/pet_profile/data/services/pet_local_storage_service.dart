import 'dart:convert';

import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/cache_service.dart';

/// ペットローカルストレージサービス
///
/// ペット情報をローカルに保存・管理します
class PetLocalStorageService {
  static const String _keyPets = 'local_pets';
  static const String _keySelectedPetId = 'selected_pet_id';

  // ✅ SharedPreferences 인스턴스 재사용
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }

  /// ペットリストを取得
  static Future<List<PetProfileEntity>> getPets() async {
    try {
      await _init();
      final petsJson = _cache.getStringList(_keyPets) ?? [];

      if (petsJson.isEmpty) {
        // 初回起動時はデフォルトペットを作成
        return await _initializeDefaultPets();
      }

      return petsJson.map((json) {
        try {
          final data = jsonDecode(json) as Map<String, dynamic>;

          // additionalInfo를 안전하게 복원
          final additionalInfo = data['additionalInfo'] is Map<String, dynamic>
              ? _sanitizeAdditionalInfo(
                  data['additionalInfo'] as Map<String, dynamic>,
                )
              : <String, dynamic>{};

          LoggerService.debug('📖 Loading pet: ${data['name']}');
          LoggerService.debug(
            '📖 additionalInfo keys: ${additionalInfo.keys.toList()}',
          );
          LoggerService.debug(
            '📖 forbiddenIngredients: ${additionalInfo['forbiddenIngredients']}',
          );

          return PetProfileEntity(
            id: data['id'] as String,
            name: data['name'] as String,
            type: data['type'] as String,
            breed: data['breed'] as String? ?? '',
            birthDate: DateTime.parse(data['birthDate'] as String),
            gender: data['gender'] as String,
            weight: (data['weight'] as num).toDouble(),
            imagePath: data['imagePath'] as String?,
            ownerId: data['ownerId'] as String,
            createdAt: DateTime.parse(data['createdAt'] as String),
            updatedAt: DateTime.parse(data['updatedAt'] as String),
            isActive: data['isActive'] as bool? ?? true,
            additionalInfo: additionalInfo,
          );
        } catch (e, stackTrace) {
          LoggerService.debug('⚠️  펫 파싱 실패: $e');
          LoggerService.debug('⚠️  스택트레이스: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      LoggerService.debug('❌ ペット取得エラー: $e');
      LoggerService.debug('❌ スタックトレース: $stackTrace');
      return [];
    }
  }

  /// 初期デフォルトペットを作成
  /// 현재는 펫이 등록되지 않은 상태로 빈 리스트 반환
  static Future<List<PetProfileEntity>> _initializeDefaultPets() async {
    // 펫이 등록되지 않은 상태 - 빈 리스트 반환
    final emptyPets = <PetProfileEntity>[];

    await savePets(emptyPets);
    return emptyPets;
  }

  /// ペットリストを保存
  static Future<void> savePets(List<PetProfileEntity> pets) async {
    try {
      await _init();
      final petsJson = pets.map((pet) {
        // additionalInfo를 안전하게 직렬화
        final safeAdditionalInfo = _sanitizeAdditionalInfo(pet.additionalInfo);

        LoggerService.debug('💾 Saving pet: ${pet.name}');
        LoggerService.debug(
          '💾 additionalInfo keys: ${safeAdditionalInfo.keys.toList()}',
        );
        LoggerService.debug(
          '💾 forbiddenIngredients: ${safeAdditionalInfo['forbiddenIngredients']}',
        );

        return jsonEncode({
          'id': pet.id,
          'name': pet.name,
          'type': pet.type,
          'breed': pet.breed,
          'birthDate': pet.birthDate.toIso8601String(),
          'gender': pet.gender,
          'weight': pet.weight,
          'imagePath': pet.imagePath,
          'ownerId': pet.ownerId,
          'createdAt': pet.createdAt.toIso8601String(),
          'updatedAt': pet.updatedAt.toIso8601String(),
          'isActive': pet.isActive,
          'additionalInfo': safeAdditionalInfo,
        });
      }).toList();

      await _cache.setStringList(_keyPets, petsJson);
      LoggerService.debug('✅ ペット保存成功: ${pets.length}匹');
    } catch (e, stackTrace) {
      LoggerService.debug('❌ ペット保存エラー: $e');
      LoggerService.debug('❌ スタックトレース: $stackTrace');
      rethrow; // 에러를 상위로 전달
    }
  }

  /// additionalInfo를 JSON 직렬화 가능한 형태로 정제
  static Map<String, dynamic> _sanitizeAdditionalInfo(
    Map<String, dynamic>? additionalInfo,
  ) {
    if (additionalInfo == null || additionalInfo.isEmpty) {
      return {};
    }

    final result = <String, dynamic>{};

    additionalInfo.forEach((key, value) {
      try {
        // List 타입 필드 처리
        if (value is List) {
          // List<String>으로 변환
          final sanitizedList = List<String>.from(value.whereType<String>());
          if (sanitizedList.isNotEmpty) {
            result[key] = sanitizedList;
            LoggerService.debug(
              '💾 [$key] List saved: ${sanitizedList.length} items',
            );
          }
        }
        // String 타입 필드 처리
        else if (value is String) {
          result[key] = value;
        }
        // num 타입 필드 처리
        else if (value is num) {
          result[key] = value;
        }
        // bool 타입 필드 처리
        else if (value is bool) {
          result[key] = value;
        }
        // Map 타입 필드 처리 (재귀적으로 정제)
        else if (value is Map<String, dynamic>) {
          result[key] = _sanitizeAdditionalInfo(value);
        }
        // 기타 타입은 toString() 처리
        else if (value != null) {
          result[key] = value.toString();
          LoggerService.debug('⚠️  [$key] 알 수 없는 타입 변환됨: ${value.runtimeType}');
        }
      } catch (e) {
        LoggerService.debug('⚠️  [$key] 필드 정제 실패: $e');
        // 실패한 필드는 제외
      }
    });

    return result;
  }

  /// ペットを追加
  static Future<PetProfileEntity> addPet(PetProfileEntity pet) async {
    final pets = await getPets();

    // IDが空なら新規生成
    final newId = pet.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : pet.id;

    final newPet = pet.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    pets.add(newPet);
    await savePets(pets);

    return newPet;
  }

  /// ペットを更新
  static Future<PetProfileEntity?> updatePet(
    PetProfileEntity updatedPet,
  ) async {
    final pets = await getPets();
    final index = pets.indexWhere((p) => p.id == updatedPet.id);

    if (index != -1) {
      pets[index] = updatedPet.copyWith(updatedAt: DateTime.now());
      await savePets(pets);
      return pets[index];
    }

    return null;
  }

  /// ペットを削除
  static Future<bool> deletePet(String id) async {
    final pets = await getPets();
    final initialLength = pets.length;

    pets.removeWhere((p) => p.id == id);

    if (pets.length < initialLength) {
      await savePets(pets);
      return true;
    }

    return false;
  }

  /// IDでペットを取得
  static Future<PetProfileEntity?> getPetById(String id) async {
    final pets = await getPets();
    try {
      return pets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 選択中のペットIDを保存
  static Future<void> saveSelectedPetId(String petId) async {
    await _init();
    await _cache.setString(_keySelectedPetId, petId);
  }

  /// 選択中のペットIDを取得
  static Future<String?> getSelectedPetId() async {
    await _init();
    return _cache.getString(_keySelectedPetId);
  }

  /// すべてのペットデータをクリア
  static Future<void> clearAll() async {
    await _init();
    await _cache.removeKey(_keyPets);
    await _cache.removeKey(_keySelectedPetId);
  }
}
