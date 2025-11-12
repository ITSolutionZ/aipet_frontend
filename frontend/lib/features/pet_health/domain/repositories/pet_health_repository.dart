import '../../../../../features/pet_health/domain/entities/vaccine_record_entity.dart';
import '../../../../../features/pet_health/domain/entities/weight_record_entity.dart';

abstract class PetHealthRepository {
  // Vaccine records
  Future<List<VaccineRecordEntity>> getVaccineRecords(String petId);
  Future<VaccineRecordEntity> addVaccineRecord(
    String petId,
    VaccineRecordEntity record,
  );
  Future<VaccineRecordEntity> updateVaccineRecord(
    String petId,
    VaccineRecordEntity record,
  );

  /// Backend API 요구사항: petId와 recordId 모두 필요
  Future<void> deleteVaccineRecord(String petId, String recordId);

  // Weight records
  Future<List<WeightRecordEntity>> getWeightRecords(String petId);
  Future<WeightRecordEntity> addWeightRecord(WeightRecordEntity record);
  Future<WeightRecordEntity> updateWeightRecord(WeightRecordEntity record);

  /// Backend API 요구사항: petId와 recordId 모두 필요
  Future<void> deleteWeightRecord(String petId, String recordId);

  // Health statistics
  Future<List<VaccineRecordEntity>> getUpcomingVaccines(String petId);
  Future<WeightRecordEntity?> getLatestWeight(String petId);
}
