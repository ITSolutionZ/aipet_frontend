import '../../../../shared/mock_data/mock_data_service.dart';
import '../../domain/entities/vaccine_record_entity.dart';
import '../../domain/entities/weight_record_entity.dart';
import '../../domain/repositories/pet_health_repository.dart';

class PetHealthRepositoryImpl implements PetHealthRepository {
  // 메모리 기반 저장소 (MockDataService의 데이터로 초기화)
  late final List<VaccineRecordEntity> _vaccineRecords;
  late final List<WeightRecordEntity> _weightRecords;

  PetHealthRepositoryImpl() {
    // MockDataService에서 초기 데이터 로드
    _vaccineRecords = List.from(MockDataService.getMockVaccineRecords());
    _weightRecords = List.from(MockDataService.getMockWeightRecords());
  }

  @override
  Future<List<VaccineRecordEntity>> getVaccineRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _vaccineRecords;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<VaccineRecordEntity> addVaccineRecord(
    VaccineRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      _vaccineRecords.add(record);
      return record;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<VaccineRecordEntity> updateVaccineRecord(
    VaccineRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      final index = _vaccineRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _vaccineRecords[index] = record;
        return record;
      }
      throw Exception('백신 기록을 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> deleteVaccineRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      _vaccineRecords.removeWhere((record) => record.id == recordId);
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<WeightRecordEntity>> getWeightRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _weightRecords.where((record) => record.petId == petId).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<WeightRecordEntity> addWeightRecord(WeightRecordEntity record) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      _weightRecords.add(record);
      return record;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<WeightRecordEntity> updateWeightRecord(
    WeightRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      final index = _weightRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _weightRecords[index] = record;
        return record;
      }
      throw Exception('체중 기록을 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      _weightRecords.removeWhere((record) => record.id == recordId);
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<VaccineRecordEntity>> getUpcomingVaccines(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _vaccineRecords
          .where((record) => record.isExpiringSoon || record.isExpired)
          .toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<WeightRecordEntity?> getLatestWeight(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      final petWeights = _weightRecords
          .where((record) => record.petId == petId)
          .toList();
      if (petWeights.isEmpty) return null;

      petWeights.sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
      return petWeights.first;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }
}
