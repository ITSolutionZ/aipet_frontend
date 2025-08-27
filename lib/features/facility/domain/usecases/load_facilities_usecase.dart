import '../facility.dart';
import '../repositories/facility_repository.dart';

class LoadFacilitiesUseCase {
  final FacilityRepository repository;

  LoadFacilitiesUseCase(this.repository);

  Future<List<Facility>> call() async {
    return repository.getNearbyFacilities();
  }
}
