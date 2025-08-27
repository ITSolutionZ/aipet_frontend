import '../entities/vaccine_record_entity.dart';
import '../entities/weight_record_entity.dart';

abstract class PetHealthRepository {
  // Vaccine records
  Future<List<VaccineRecordEntity>> getVaccineRecords(String petId);
  Future<VaccineRecordEntity> addVaccineRecord(VaccineRecordEntity record);
  Future<VaccineRecordEntity> updateVaccineRecord(VaccineRecordEntity record);
  Future<void> deleteVaccineRecord(String recordId);

  // Weight records
  Future<List<WeightRecordEntity>> getWeightRecords(String petId);
  Future<WeightRecordEntity> addWeightRecord(WeightRecordEntity record);
  Future<WeightRecordEntity> updateWeightRecord(WeightRecordEntity record);
  Future<void> deleteWeightRecord(String recordId);

  // Health statistics
  Future<List<VaccineRecordEntity>> getUpcomingVaccines(String petId);
  Future<WeightRecordEntity?> getLatestWeight(String petId);
}
