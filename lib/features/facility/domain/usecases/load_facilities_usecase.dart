import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';

class LoadFacilitiesUseCase {
  final FacilityRepository repository;

  LoadFacilitiesUseCase(this.repository);

  Future<List<Facility>> call() async {
    final result = await repository.getNearbyFacilities();
    if (result.isSuccess) {
      return result.data ?? [];
    } else {
      throw Exception(result.error?.toString() ?? 'Failed to load facilities');
    }
  }
}
