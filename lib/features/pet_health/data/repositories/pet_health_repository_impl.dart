import '../../../../shared/testing/mock_data/features/pet_health/pet_health_mock_service.dart';
import '../../domain/entities/vaccine_record_entity.dart';
import '../../domain/entities/weight_record_entity.dart';
import '../../domain/repositories/pet_health_repository.dart';

class PetHealthRepositoryImpl implements PetHealthRepository {
  // 메모리 기반 저장소 (PetHealthMockService의 데이터로 초기화)
  late final List<VaccineRecordEntity> _vaccineRecords;
  late final List<WeightRecordEntity> _weightRecords;

  PetHealthRepositoryImpl() {
    // PetHealthMockService에서 초기 데이터 로드
    final vaccineData = PetHealthMockService.getMockVaccineRecords();
    _vaccineRecords = vaccineData.map((data) => VaccineRecordEntity(
      id: data['id'] as String,
      name: data['vaccineName'] as String,
      date: data['vaccineDate'] as DateTime,
      doctor: data['veterinarian'] as String,
      notes: data['notes'] as String?,
    )).toList();
    
    final weightData = PetHealthMockService.getMockWeightRecords();
    _weightRecords = weightData.map((data) => WeightRecordEntity(
      id: data['id'] as String,
      petId: data['petId'] as String,
      petName: data['petName'] as String? ?? 'Unknown',
      recordedDate: data['measurementDate'] as DateTime,
      weight: data['weight'] as double,
      notes: data['notes'] as String?,
      createdAt: data['measurementDate'] as DateTime,
    )).toList();
  }

  @override
  Future<List<VaccineRecordEntity>> getVaccineRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vaccineRecords;
  }

  @override
  Future<VaccineRecordEntity> addVaccineRecord(
    VaccineRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _vaccineRecords.add(record);
    return record;
  }

  @override
  Future<VaccineRecordEntity> updateVaccineRecord(
    VaccineRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _vaccineRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _vaccineRecords[index] = record;
      return record;
    }
    throw Exception('백신 기록을 찾을 수 없습니다');
  }

  @override
  Future<void> deleteVaccineRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _vaccineRecords.removeWhere((record) => record.id == recordId);
  }

  @override
  Future<List<WeightRecordEntity>> getWeightRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _weightRecords.where((record) => record.petId == petId).toList();
  }

  @override
  Future<WeightRecordEntity> addWeightRecord(WeightRecordEntity record) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _weightRecords.add(record);
    return record;
  }

  @override
  Future<WeightRecordEntity> updateWeightRecord(
    WeightRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _weightRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _weightRecords[index] = record;
      return record;
    }
    throw Exception('체중 기록을 찾을 수 없습니다');
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _weightRecords.removeWhere((record) => record.id == recordId);
  }

  @override
  Future<List<VaccineRecordEntity>> getUpcomingVaccines(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vaccineRecords
        .where((record) => record.isExpiringSoon || record.isExpired)
        .toList();
  }

  @override
  Future<WeightRecordEntity?> getLatestWeight(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final petWeights = _weightRecords
        .where((record) => record.petId == petId)
        .toList();
    if (petWeights.isEmpty) return null;

    petWeights.sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
    return petWeights.first;
  }
}