import 'package:aipet_frontend/features/pet_health/data/services/pet_health_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_health/domain/entities/vaccine_record_entity.dart';
import 'package:aipet_frontend/features/pet_health/domain/entities/weight_record_entity.dart';
import 'package:aipet_frontend/features/pet_health/domain/repositories/pet_health_repository.dart';

class PetHealthRepositoryImpl implements PetHealthRepository {
  PetHealthRepositoryImpl();

  @override
  Future<List<VaccineRecordEntity>> getVaccineRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recordsData = await PetHealthLocalStorageService.getVaccineRecords(
      petId: petId,
    );

    return recordsData.map((data) {
      return VaccineRecordEntity(
        id: data['id'] as String,
        name: data['vaccineName'] as String,
        date: DateTime.parse(data['vaccineDate'] as String),
        doctor: data['veterinarian'] as String,
        notes: data['notes'] as String?,
      );
    }).toList();
  }

  @override
  Future<VaccineRecordEntity> addVaccineRecord(
    VaccineRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recordData = {
      'id': record.id,
      'petId': 'default',
      'vaccineName': record.name,
      'vaccineDate': record.date.toIso8601String(),
      'veterinarian': record.doctor,
      'notes': record.notes,
    };

    await PetHealthLocalStorageService.addVaccineRecord(recordData);

    return record;
  }

  @override
  Future<VaccineRecordEntity> updateVaccineRecord(
    VaccineRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recordData = {
      'id': record.id,
      'petId': 'default',
      'vaccineName': record.name,
      'vaccineDate': record.date.toIso8601String(),
      'veterinarian': record.doctor,
      'notes': record.notes,
    };

    await PetHealthLocalStorageService.updateVaccineRecord(recordData);

    return record;
  }

  @override
  Future<void> deleteVaccineRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    await PetHealthLocalStorageService.deleteVaccineRecord(recordId);
  }

  @override
  Future<List<WeightRecordEntity>> getWeightRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recordsData = await PetHealthLocalStorageService.getWeightRecords(
      petId: petId,
    );

    return recordsData.map((data) {
      return WeightRecordEntity(
        id: data['id'] as String,
        petId: data['petId'] as String,
        petName: data['petName'] as String? ?? 'Unknown',
        recordedDate: DateTime.parse(data['measurementDate'] as String),
        weight: (data['weight'] as num).toDouble(),
        notes: data['notes'] as String?,
        createdAt: DateTime.parse(data['measurementDate'] as String),
      );
    }).toList();
  }

  @override
  Future<WeightRecordEntity> addWeightRecord(WeightRecordEntity record) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recordData = {
      'id': record.id,
      'petId': record.petId,
      'petName': record.petName,
      'measurementDate': record.recordedDate.toIso8601String(),
      'weight': record.weight,
      'notes': record.notes,
    };

    await PetHealthLocalStorageService.addWeightRecord(recordData);

    return record;
  }

  @override
  Future<WeightRecordEntity> updateWeightRecord(
    WeightRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recordData = {
      'id': record.id,
      'petId': record.petId,
      'petName': record.petName,
      'measurementDate': record.recordedDate.toIso8601String(),
      'weight': record.weight,
      'notes': record.notes,
    };

    await PetHealthLocalStorageService.updateWeightRecord(recordData);

    return record;
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    await PetHealthLocalStorageService.deleteWeightRecord(recordId);
  }

  @override
  Future<List<VaccineRecordEntity>> getUpcomingVaccines(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final records = await getVaccineRecords(petId);

    return records
        .where((record) => record.isExpiringSoon || record.isExpired)
        .toList();
  }

  @override
  Future<WeightRecordEntity?> getLatestWeight(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final petWeights = await getWeightRecords(petId);

    if (petWeights.isEmpty) return null;

    petWeights.sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
    return petWeights.first;
  }
}
