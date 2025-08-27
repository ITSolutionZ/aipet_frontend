import '../repositories/facility_repository.dart';

class SetCurrentLocationUseCase {
  final FacilityRepository repository;

  SetCurrentLocationUseCase(this.repository);

  Future<void> call(double latitude, double longitude, String address) async {
    return repository.setCurrentLocation(latitude, longitude, address);
  }
}
