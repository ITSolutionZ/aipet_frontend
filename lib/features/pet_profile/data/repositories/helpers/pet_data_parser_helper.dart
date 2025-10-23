import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';

/// Pet 데이터 파싱 헬퍼
class PetDataParserHelper {
  /// 안전한 PetProfileEntity 생성 (필드가 없거나 잘못된 형식일 때 대응)
  static PetProfileEntity safeCreatePetEntity(Map<String, dynamic> petData) {
    try {
      // fromJson을 먼저 시도해보고, 실패하면 수동으로 생성
      return PetProfileEntity.fromJson(petData);
    } catch (e) {
      LoggerService.debug('PetProfileEntity.fromJson failed, creating manually: $e');
      LoggerService.debug('Pet data keys: ${petData.keys.toList()}');
      LoggerService.debug('Pet data: $petData');

      // 수동으로 안전하게 PetProfileEntity 생성
      return PetProfileEntity(
        id: petData['id']?.toString() ?? '',
        name: petData['name']?.toString() ?? '',
        type:
            petData['typeName']?.toString() ??
            petData['type']?.toString() ??
            'dog',
        breed: petData['breed']?.toString(),
        birthDate: parseDate(petData['birthDate']) ?? DateTime.now(),
        gender: petData['gender']?.toString() ?? 'unknown',
        weight: parseDouble(petData['weight']) ?? 0.0,
        imagePath: petData['imagePath']?.toString(),
        ownerId: petData['ownerId']?.toString() ?? 'unknown',
        createdAt: parseDate(petData['createdAt']) ?? DateTime.now(),
        updatedAt: parseDate(petData['updatedAt']) ?? DateTime.now(),
        isActive: petData['isActive'] as bool? ?? true,
        additionalInfo:
            petData['additionalInfo'] as Map<String, dynamic>? ?? {},
        neutered: petData['neutered'] as bool? ?? false,
      );
    }
  }

  /// 안전한 DateTime 파싱
  static DateTime? parseDate(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is DateTime) return dateValue;

    if (dateValue is String) {
      return DateTime.tryParse(dateValue);
    }

    return null;
  }

  /// 안전한 double 파싱
  static double? parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}
