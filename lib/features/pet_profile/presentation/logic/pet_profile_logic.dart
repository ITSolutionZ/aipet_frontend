import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pet Profile 비즈니스 로직 클래스
///
/// UI와 완전히 분리된 순수한 비즈니스 로직을 담당합니다.
/// Clean Architecture의 Use Case 레이어 역할을 수행합니다.
class PetProfileLogic {
  final Ref _ref;

  PetProfileLogic(this._ref);

  /// 펫 프로필 로드
  Future<Result<PetProfileEntity?>> loadPetProfile(String petId) async {
    try {
      LoggerService.debug('🔍 PetProfileLogic: Loading pet with ID: $petId');
      final repository = _ref.read(petProfileRepositoryProvider);
      final result = await repository.getPetById(petId);

      if (result.isSuccess) {
        if (result.dataOrNull != null) {
          LoggerService.debug(
            '✅ PetProfileLogic: Pet found: ${result.dataOrNull!.name}',
          );
          return Result.success('ペット情報を取得しました', result.dataOrNull);
        } else {
          LoggerService.debug('❌ PetProfileLogic: Pet not found with ID: $petId');
          return Result.failure('ペットが見つかりません (ID: $petId)');
        }
      } else {
        LoggerService.debug('❌ PetProfileLogic: Repository error: ${result.message}');
        return Result.failure(result.message);
      }
    } catch (e) {
      LoggerService.debug('❌ PetProfileLogic: Exception: ${e.toString()}');
      return Result.failure('ペット情報の取得に失敗しました: ${e.toString()}');
    }
  }

  /// 펫 프로필 업데이트
  Future<Result<PetProfileEntity>> updatePetProfile(
    PetProfileEntity pet,
  ) async {
    try {
      final repository = _ref.read(petProfileRepositoryProvider);
      final result = await repository.updatePet(pet);

      if (result.isSuccess) {
        // 펫 목록 새로고침
        await _ref.read(petProfilesProvider.notifier).refresh();
        return Result.success('ペット情報を更新しました', result.dataOrNull!);
      } else {
        return Result.failure(result.message);
      }
    } catch (e) {
      return Result.failure('ペット情報の更新に失敗しました: ${e.toString()}');
    }
  }

  /// 펫 프로필 삭제
  Future<Result<void>> deletePetProfile(String petId) async {
    try {
      final repository = _ref.read(petProfileRepositoryProvider);
      final result = await repository.deletePet(petId);

      if (result.isSuccess) {
        // 펫 목록 새로고침
        await _ref.read(petProfilesProvider.notifier).refresh();
        return Result.success('ペットを削除しました', null);
      } else {
        return Result.failure(result.message);
      }
    } catch (e) {
      return Result.failure('ペットの削除に失敗しました: ${e.toString()}');
    }
  }

  /// 펫 이미지 업로드
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    try {
      final repository = _ref.read(petProfileRepositoryProvider);
      final result = await repository.uploadPetImage(petId, imagePath);

      if (result.isSuccess) {
        // 펫 목록 새로고침
        await _ref.read(petProfilesProvider.notifier).refresh();
        return Result.success('画像をアップロードしました', result.dataOrNull!);
      } else {
        return Result.failure(result.message);
      }
    } catch (e) {
      return Result.failure('画像のアップロードに失敗しました: ${e.toString()}');
    }
  }

  /// 펫 프로필 공유 설정 업데이트
  Future<Result<void>> updateSharingSettings(
    String petId,
    bool isPublic,
  ) async {
    try {
      final repository = _ref.read(petProfileRepositoryProvider);
      final result = await repository.updateSharingSettings(petId, isPublic);

      if (result.isSuccess) {
        return Result.success('共有設定を更新しました', null);
      } else {
        return Result.failure(result.message);
      }
    } catch (e) {
      return Result.failure('共有設定の更新に失敗しました: ${e.toString()}');
    }
  }

  /// 편집 권한 확인
  bool canEditProfile(PetProfileEntity pet, String userId) {
    return pet.ownerId == userId;
  }

  /// 공유 가능 여부 확인
  bool canShareProfile(PetProfileEntity pet) {
    return pet.isActive;
  }

  /// 펫 타입 아이콘 반환
  String getPetTypeIcon(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'hamster':
        return '🐹';
      case 'rabbit':
        return '🐰';
      case 'turtle':
        return '🐢';
      default:
        return '🐾';
    }
  }

  /// 펫 타입 이름 반환 (일본어)
  String getPetTypeName(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'bird':
        return '鳥';
      case 'hamster':
        return 'ハムスター';
      case 'rabbit':
        return 'うさぎ';
      case 'turtle':
        return '亀';
      default:
        return 'ペット';
    }
  }

  /// 성별 표시명 반환 (일본어)
  String getGenderDisplayName(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'オス':
        return 'オス';
      case 'female':
      case 'メス':
        return 'メス';
      default:
        return '不明';
    }
  }

  /// 나이 계산
  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// 생년월일 포맷팅 (일본어)
  String formatBirthDate(DateTime birthDate) {
    return '${birthDate.year}年${birthDate.month}月${birthDate.day}日';
  }

  /// 권장 산책 시간 계산 (분 단위)
  int getRecommendedWalkTime(PetProfileEntity pet) {
    if (pet.type.toLowerCase() == 'dog') {
      if (pet.weight < 10) {
        return 30; // 소형견
      } else if (pet.weight < 25) {
        return 45; // 중형견
      } else {
        return 60; // 대형견
      }
    } else if (pet.type.toLowerCase() == 'cat') {
      return 20;
    }
    return 15;
  }
}
