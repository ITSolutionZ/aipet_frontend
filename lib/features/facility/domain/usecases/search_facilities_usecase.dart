import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';

class SearchFacilitiesUseCase {
  final FacilityRepository repository;

  SearchFacilitiesUseCase(this.repository);

  Future<List<Facility>> call(String query) async {
    final result = await repository.searchFacilities(query);
    if (result.isSuccess) {
      return result.dataOrNull ?? [];
    } else {
      throw Exception(
        result.errorOrNull?.toString() ?? 'Failed to search facilities',
      );
    }
  }
}
