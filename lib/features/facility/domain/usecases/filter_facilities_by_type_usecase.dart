import '../facility.dart';
import '../repositories/facility_repository.dart';

class FilterFacilitiesByTypeUseCase {
  final FacilityRepository repository;

  FilterFacilitiesByTypeUseCase(this.repository);

  Future<List<Facility>> call(FacilityType type) async {
    return repository.getFacilitiesByType(type);
  }
}
