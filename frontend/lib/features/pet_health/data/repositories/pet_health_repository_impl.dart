import '../../../../shared/shared.dart';
import '../services/backend_health_api_service.dart';
import '../../domain/entities/vaccine_record_entity.dart';
import '../../domain/entities/weight_record_entity.dart';
import '../../domain/repositories/pet_health_repository.dart';

/// Pet Health Repository 구현체
/// Backend API 연동 (BackendHealthApiService 사용)
class PetHealthRepositoryImpl implements PetHealthRepository {
  PetHealthRepositoryImpl();

  // =========================================================================
  // Vaccine Records
  // =========================================================================

  @override
  Future<List<VaccineRecordEntity>> getVaccineRecords(String petId) async {
    final result = await BackendHealthApiService.getVaccinations(petId: petId);

    if (result.isSuccess) {
      final vaccinations = result.dataOrNull ?? [];
      final records = vaccinations.map((data) {
        return _mapToVaccineEntity(data);
      }).toList();

      LoggerService.debug(
        '✅ PetHealthRepository: 예방접종 기록 ${records.length}개 조회 (Backend API)',
      );
      return records;
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 예방접종 기록 조회 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<VaccineRecordEntity> addVaccineRecord(
    String petId,
    VaccineRecordEntity record,
  ) async {
    final result = await BackendHealthApiService.createVaccination(
      petId: petId,
      vaccineName: record.name,
      vaccinationDate: record.date,
      nextDueDate: record.validUntil,
      veterinarianName: record.doctor,
      notes: record.notes,
    );

    if (result.isSuccess) {
      final data = result.dataOrNull!;
      final createdRecord = _mapToVaccineEntity(data);

      LoggerService.debug(
        '✅ PetHealthRepository: 예방접종 기록 추가 - ID: ${createdRecord.id} (Backend API)',
      );
      return createdRecord;
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 예방접종 기록 추가 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<VaccineRecordEntity> updateVaccineRecord(
    String petId,
    VaccineRecordEntity record,
  ) async {
    final result = await BackendHealthApiService.updateVaccination(
      petId: petId,
      vaccinationId: record.id,
      vaccineName: record.name,
      vaccinationDate: record.date,
      nextDueDate: record.validUntil,
      veterinarianName: record.doctor,
      notes: record.notes,
    );

    if (result.isSuccess) {
      final data = result.dataOrNull!;
      final updatedRecord = _mapToVaccineEntity(data);

      LoggerService.debug(
        '✅ PetHealthRepository: 예방접종 기록 업데이트 - ID: ${updatedRecord.id} (Backend API)',
      );
      return updatedRecord;
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 예방접종 기록 업데이트 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<void> deleteVaccineRecord(String petId, String recordId) async {
    final result = await BackendHealthApiService.deleteVaccination(
      petId: petId,
      vaccinationId: recordId,
    );

    if (result.isSuccess) {
      LoggerService.debug(
        '✅ PetHealthRepository: 예방접종 기록 삭제 - ID: $recordId (Backend API)',
      );
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 예방접종 기록 삭제 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  // =========================================================================
  // Weight Records
  // =========================================================================

  @override
  Future<List<WeightRecordEntity>> getWeightRecords(String petId) async {
    final result = await BackendHealthApiService.getWeightHistory(petId: petId);

    if (result.isSuccess) {
      final weights = result.dataOrNull ?? [];
      final records = weights.map((data) {
        return _mapToWeightEntity(data, petId);
      }).toList();

      LoggerService.debug(
        '✅ PetHealthRepository: 체중 기록 ${records.length}개 조회 (Backend API)',
      );
      return records;
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 체중 기록 조회 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<WeightRecordEntity> addWeightRecord(WeightRecordEntity record) async {
    final result = await BackendHealthApiService.createWeightRecord(
      petId: record.petId,
      weight: record.weight,
      measuredAt: record.recordedDate,
      notes: record.notes,
    );

    if (result.isSuccess) {
      final data = result.dataOrNull!;
      final createdRecord = _mapToWeightEntity(data, record.petId);

      LoggerService.debug(
        '✅ PetHealthRepository: 체중 기록 추가 - ID: ${createdRecord.id} (Backend API)',
      );
      return createdRecord;
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 체중 기록 추가 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<WeightRecordEntity> updateWeightRecord(
    WeightRecordEntity record,
  ) async {
    final result = await BackendHealthApiService.updateWeightRecord(
      petId: record.petId,
      weightId: record.id,
      weight: record.weight,
      measuredAt: record.recordedDate,
      notes: record.notes,
    );

    if (result.isSuccess) {
      final data = result.dataOrNull!;
      final updatedRecord = _mapToWeightEntity(data, record.petId);

      LoggerService.debug(
        '✅ PetHealthRepository: 체중 기록 업데이트 - ID: ${updatedRecord.id} (Backend API)',
      );
      return updatedRecord;
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 체중 기록 업데이트 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<void> deleteWeightRecord(String petId, String recordId) async {
    final result = await BackendHealthApiService.deleteWeightRecord(
      petId: petId,
      weightId: recordId,
    );

    if (result.isSuccess) {
      LoggerService.debug(
        '✅ PetHealthRepository: 체중 기록 삭제 - ID: $recordId (Backend API)',
      );
    } else {
      LoggerService.error(
        '❌ PetHealthRepository: 체중 기록 삭제 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  // =========================================================================
  // Health Statistics
  // =========================================================================

  @override
  Future<List<VaccineRecordEntity>> getUpcomingVaccines(String petId) async {
    final records = await getVaccineRecords(petId);

    final upcomingVaccines = records
        .where((record) => record.isExpiringSoon || record.isExpired)
        .toList();

    LoggerService.debug(
      '✅ PetHealthRepository: 예정된 예방접종 ${upcomingVaccines.length}개 조회',
    );

    return upcomingVaccines;
  }

  @override
  Future<WeightRecordEntity?> getLatestWeight(String petId) async {
    final petWeights = await getWeightRecords(petId);

    if (petWeights.isEmpty) {
      LoggerService.debug('⚠️ PetHealthRepository: 체중 기록이 없음');
      return null;
    }

    petWeights.sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
    final latestWeight = petWeights.first;

    LoggerService.debug(
      '✅ PetHealthRepository: 최근 체중 기록 조회 - ${latestWeight.weight}kg',
    );

    return latestWeight;
  }

  // =========================================================================
  // Private Helper Methods
  // =========================================================================

  /// Backend API 응답을 VaccineRecordEntity로 변환
  VaccineRecordEntity _mapToVaccineEntity(Map<String, dynamic> data) {
    return VaccineRecordEntity(
      id: data['id']?.toString() ?? data['vaccinationId']?.toString() ?? '',
      name: data['vaccineName'] as String? ?? '',
      date: _parseDateTime(data['vaccinationDate']) ?? DateTime.now(),
      doctor: data['veterinarianName'] as String? ?? '',
      lot: data['lot'] as String?,
      expiryDate: _parseDateTime(data['expiryDate']),
      validUntil: _parseDateTime(data['nextDueDate']),
      notes: data['notes'] as String?,
    );
  }

  /// Backend API 응답을 WeightRecordEntity로 변환
  WeightRecordEntity _mapToWeightEntity(
    Map<String, dynamic> data,
    String petId,
  ) {
    final measuredAt = _parseDateTime(data['measuredAt']) ?? DateTime.now();

    return WeightRecordEntity(
      id: data['id']?.toString() ?? data['weightId']?.toString() ?? '',
      petId: petId,
      petName: data['petName'] as String? ?? 'Unknown',
      recordedDate: measuredAt,
      weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] as String?,
      createdAt: _parseDateTime(data['createdAt']) ?? measuredAt,
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  /// DateTime 파싱 헬퍼
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        LoggerService.warning('⚠️ DateTime 파싱 실패: $value');
        return null;
      }
    }
    return null;
  }
}
