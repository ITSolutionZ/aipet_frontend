import '../facility.dart';
import '../repositories/facility_repository.dart';

class SearchFacilitiesUseCase {
  final FacilityRepository repository;

  SearchFacilitiesUseCase(this.repository);

  Future<List<Facility>> call(String query) async {
    return repository.searchFacilities(query);
  }
}
