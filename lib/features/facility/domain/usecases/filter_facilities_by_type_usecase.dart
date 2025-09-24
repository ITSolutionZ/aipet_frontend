import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';

class FilterFacilitiesByTypeUseCase {
  final FacilityRepository repository;

  FilterFacilitiesByTypeUseCase(this.repository);

  Future<List<Facility>> call(FacilityType type) async {
    final result = await repository.getFacilitiesByType(type);
    if (result.isSuccess) {
      return result.data ?? [];
    } else {
      throw Exception(
        result.error?.toString() ?? 'Failed to filter facilities',
      );
    }
  }
}
